# frozen_string_literal: true

class Users::PaymentMethodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:update]

  def show
    modalist
    authorize! :read, current_user
  end

  def edit
    modalist
    authorize! :update, current_user
  end

  def update
    authorize! :update, current_user
    if params.has_key?(:stripeToken) && !params[:stripeToken].nil? && !params[:stripeToken] == ''
      @customer.source = params[:stripeToken]
      @customer.save
      current_user.update_attributes has_payment_method: true unless current_user.has_payment_method?
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: subscriptions_url, notice: (params.has_key?(:stripeToken) && !params[:stripeToken].nil? && !params[:stripeToken] == '' ? I18n.t('users.payment_methods.update.success') : I18n.t('users.payment_methods.update.error')) }
      format.js { head :ok }
    end
  end

  private

  def set_customer
    @customer = Stripe::Customer.retrieve current_user.stripe_customer_id
  end
end
