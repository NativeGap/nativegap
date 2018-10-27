# frozen_string_literal: true

module Billing
  module Subscription
    class CreateStripe
      attr_reader :subscription, :stripe_customer_id, :plan

      def initialize(subscription:, stripe_customer_id:, plan:)
        @subscription = subscription
        @stripe_customer_id = stripe_customer_id
        @plan = plan
      end

      def perform
        stripe_subscription = create_stripe_subscription
        update_subsciption(stripe_subscription)
        build_app

        stripe_subscription
      end

      private

      def create_stripe_subscription
        Stripe::Subscription.create(
          customer: @stripe_customer_id,
          items: [{ plan: @plan }],
          metadata: { id: @subscription.id }
        )
      end

      def update_subsciption(stripe_subscription)
        @subscription.update!(
          stripe_subscription_id: stripe_subscription.id,
          current_period_end: Time.strptime(
            stripe_subscription.current_period_end.to_s, '%s'
          )
        )
      end

      def build_app
        @subscription.build.build
      end
    end
  end
end
