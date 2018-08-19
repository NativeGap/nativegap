# frozen_string_literal: true

module Billing
  module Subscription
    class RetrieveStripe
      attr_reader :stripe_subscription_id

      def initialize(stripe_subscription_id:)
        @stripe_subscription_id = stripe_subscription_id
      end

      def perform
        Stripe::Subscription.retrieve(@stripe_subscription_id)
      end
    end
  end
end
