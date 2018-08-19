# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:stripe_webhook]
  before_action :set_subscription, only: [:update, :destroy]

  layout 'app'

  def index
    turbolinks_animate 'fadein'
    @subscriptions = current_user.subscriptions.uncanceled.order(:updated_at)
    @invoices = current_user.invoices.order(:created_at)
  end

  def new
    @price = Settings.nativegap.pricing
                     .send(App::Build.find(params[:build]).platform)&
                     .send(params[:plan])
    modalist
  end

  def create
    build = App::Build.find(params[:build])
    subscription = Subscription.new(
      user: current_user,
      build: build,
      plan: "#{build.platform}_#{params[:plan]}"
    )
    authorize! :create, subscription

    handle_create(subscription)
  end

  def update
    authorize! :update, @subscription

    @subscription.enable

    redirect_back fallback_location: @subscription.build.app,
                  notice: I18n.t('subscriptions.update.success')
  end

  def destroy
    authorize! :destroy, @subscription

    @subscription.cancel

    redirect_back fallback_location: root_url,
                  notice: I18n.t('subscriptions.destroy.success')
  end

  def stripe_webhook
    subscription_id =
      params.dig(:data, :object, :lines, :data)&.first&.dig(:metadata, :id)
    subscription = Subscription.find(subscription_id)

    subscription.process_payment(response: params[:type])
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def handle_create(subscription)
    if params.key(:stripeToken)
      current_user.enable_stripe(token: params[:stripeToken])
    end

    subscription.create_stripe

    redirect_back fallback_location: subscription.build.app,
                  notice: I18n.t('subscriptions.create.success')
  rescue Stripe::CardError => error
    redirect_back fallback_location: subscription.build.app, alert: error
  end
end
