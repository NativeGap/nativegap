# frozen_string_literal: true

module Billing
  module Customer
    class RetrieveStripe
      attr_reader :stripe_customer_id

      def initialize(stripe_customer_id:)
        @stripe_customer_id = stripe_customer_id
      end

      def perform
        Stripe::Customer.retrieve(@stripe_customer_id)
      end
    end
  end
end
