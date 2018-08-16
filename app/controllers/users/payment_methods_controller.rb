# frozen_string_literal: true

module Users
  class PaymentMethodsController < ApplicationController
    before_action :authenticate_user!

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
      if stripe_successful?
        current_user.enable_stripe(token: params[:stripeToken])
        unless current_user.has_payment_method?
          current_user.update!(has_payment_method: true)
        end
      end

      respond_to do |format|
        format.html do
          if stripe_successful?
            redirect_back fallback_location: subscriptions_url,
                          notice: I18n.t('users.payment_methods.update.success')
          else
            redirect_back fallback_location: subscriptions_url,
                          alert: I18n.t('users.payment_methods.update.error')
          end
        end
        format.js { head :ok }
      end
    end

    private

    def stripe_successful?
      params.key?(:stripeToken) && !params[:stripeToken].nil? &&
        !params[:stripeToken] == ''
    end
  end
end
