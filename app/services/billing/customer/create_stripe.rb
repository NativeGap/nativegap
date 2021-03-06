# frozen_string_literal: true

module Billing
  module Customer
    class CreateStripe
      attr_reader :name, :email

      def initialize(name:, email:)
        @name = name
        @email = email
      end

      def perform
        Stripe::Customer.create(description: @name, email: @email)
      end
    end
  end
end
