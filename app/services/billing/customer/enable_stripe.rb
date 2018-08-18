# frozen_string_literal: true

module Billing
  module Customer
    class EnableStripe
      attr_reader :stripe_customer, :token

      def initialize(stripe_customer:, token:)
        @stripe_customer = stripe_customer
        @token = token
      end

      def perform
        @stripe_customer.source = @token
        @stripe_customer.save!
      end
    end
  end
end
