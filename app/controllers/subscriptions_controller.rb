# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:stripe_webhook]
  before_action :set_customer, except: [:index, :new, :stripe_webhook]
  before_action :set_subscription, only: [:update, :destroy]

  layout 'app'

  def index
    turbolinks_animate 'fadein'
    @subscriptions = current_user.subscriptions.order(:updated_at)
                     .select { |subscription| subscription.canceled? == false }
    @invoices = current_user.invoices.order(:created_at)
  end

  def new
    @price = Settings.nativegap.pricing.send(App::Build.find(params[:build]).platform)&.send(params[:plan])
    modalist
  end

  def create
    @subscription = Subscription.new
    authorize! :create, @subscription
    @subscription.user = current_user
    @subscription.build = App::Build.find(params[:build])
    @subscription.plan = "#{@subscription.build.platform}_#{params[:plan]}"

    if params.key?(:token)
      @customer.source = params[:token]
      @customer.save!
    end

    begin
      @stripe_subscription = Stripe::Subscription.create(
        customer: @customer.id,
        items: [{
          plan: @subscription.plan
        }],
        metadata: {
          id: @subscription.id
        }
      )

      @subscription.stripe_subscription_id = @stripe_subscription.id
      @subscription.current_period_end =
        Time.at(@stripe_subscription.current_period_end).to_datetime
      @subscription.save!

      @subscription.build.build

      redirect_back fallback_location: @subscription.build.app,
                    notice: I18n.t('subscriptions.create.success')
    rescue Stripe::CardError => error
      redirect_back fallback_location: @subscription.build.app, alert: error
    end
  end

  def update
    authorize! :update, @subscription
    set_stripe_subscription(@subscription.stripe_subscription_id)
    @stripe_subscription.save

    @subscription.canceled_at = nil if @stripe_subscription.canceled_at.nil?
    @subscription.save!

    redirect_back fallback_location: @subscription.build.app,
                  notice: I18n.t('subscriptions.update.success')
  end

  def destroy
    authorize! :destroy, @subscription
    set_stripe_subscription(@subscription.stripe_subscription_id)
    @stripe_subscription.delete at_period_end: true

    unless @stripe_subscription.canceled_at.nil?
      @subscription.canceled_at =
        Time.at(@stripe_subscription.canceled_at).to_datetime
      @subscription.save!
    end

    redirect_back fallback_location: root_url,
                  notice: I18n.t('subscriptions.destroy.success')
  end

  def stripe_webhook
    stripe_subscription_id =
      params.dig(:data, :object, :lines, :data)&.first&.dig(:id)
    subscription_id =
      params.dig(:data, :object, :lines, :data)&.first&.dig(:metadata, :id)
    set_stripe_subscription(stripe_subscription_id)
    @subscription = Subscription.find(subscription_id)

   if params[:type] == 'invoice.payment_succeeded'
      @subscription.current_period_end =
        Time.at(@stripe_subscription.current_period_end).to_datetime
      Subscription::Invoice.create!(
        subscription: @subscription,
        amount: @stripe_subscription.plan.amount
      )
    end
    if params[:type] == 'invoice.payment_succeeded' ||
       params[:type] == 'invoice.payment_failed' ||
       params[:type] == 'invoice.upcoming'
      current_user.notify(
        object: @subscription,
        type: params[:type],
        push: :ActionMailer
      )
    end
    @subscription.save!
  end

  private

  def set_stripe_subscription(stripe_subscription_id)
    @stripe_subscription =
      Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  def set_subscription
    @subscription = Subscription.find params[:id]
  end

  def set_customer
    @customer = Stripe::Customer.retrieve current_user.stripe_customer_id
  end
end
