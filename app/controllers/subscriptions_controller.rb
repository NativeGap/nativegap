# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:stripe_webhook]
  before_action :set_customer, except: [:index, :new, :stripe_webhook]
  before_action :set_subscription, only: [:update, :destroy]

  layout 'app'

  def index
    turbolinks_animate 'fadein'
    @subscriptions = current_user.subscriptions.order(:updated_at).select { |subscription| subscription.canceled? == false }
    @invoices = current_user.invoices.order(:created_at)
  end

  def new
    modalist
  end

  def create
    @subscription = Subscription.new
    authorize! :create, @subscription
    @subscription.user = current_user
    @subscription.build = App::Build.find params[:build]
    @subscription.plan = "#{@subscription.build.platform}_#{params[:plan]}"

    if params.has_key? :token
      @customer.source = params[:token]
      @customer.save!
    end

    begin
      subscription = Stripe::Subscription.create(
        customer: @customer.id,
        items: [{
          plan: @subscription.plan
        }],
        metadata: {
          id: @subscription.id
        }
      )

      @subscription.stripe_subscription_id = subscription.id
      @subscription.current_period_end = Time.at(subscription.current_period_end).to_datetime
      @subscription.save!

      @subscription.build.build

      redirect_back fallback_location: @subscription.build.app, notice: I18n.t('subscriptions.create.success')
    rescue Stripe::CardError => e
      redirect_back fallback_location: @subscription.build.app, alert: e
    end
  end

  def update
    authorize! :update, @subscription
    subscription = Stripe::Subscription.retrieve @subscription.stripe_subscription_id
    subscription.save

    @subscription.canceled_at = nil if subscription.canceled_at.nil?
    @subscription.save!

    redirect_back fallback_location: @subscription.build.app, notice: I18n.t('subscriptions.update.success')
  end

  def destroy
    authorize! :destroy, @subscription
    subscription = Stripe::Subscription.retrieve @subscription.stripe_subscription_id
    subscription.delete at_period_end: true

    @subscription.canceled_at = Time.at(subscription.canceled_at).to_datetime unless subscription.canceled_at.nil?
    @subscription.save!

    redirect_back fallback_location: root_url, notice: I18n.t('subscriptions.destroy.success')
  end

  def stripe_webhook
    subscription = Stripe::Subscription.retrieve params.dig(:data, :object, :lines, :data)&.first&.dig(:id)
    @subscription = Subscription.find params.dig(:data, :object, :lines, :data)&.first&.dig(:metadata, :id)

    case params[:type]
    when 'invoice.payment_succeeded'
      @subscription.current_period_end = Time.at(subscription.current_period_end).to_datetime
      Subscription::Invoice.create! subscription: @subscription, amount: subscription.plan.amount
      current_user.notify object: @subscription, type: params[:type], push: :ActionMailer
    when 'invoice.payment_failed'
      current_user.notify object: @subscription, type: params[:type], push: :ActionMailer
    when 'invoice.upcoming'
      current_user.notify object: @subscription, type: params[:type], push: :ActionMailer
    end
    @subscription.save!
  end

  private

  def set_subscription
    @subscription = Subscription.find params[:id]
  end
  def set_customer
    @customer = Stripe::Customer.retrieve current_user.stripe_customer_id
  end
end
