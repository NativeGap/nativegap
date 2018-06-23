# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true
      t.references :build, index: true

      # Stripe
      t.string :plan
      t.string :stripe_subscription_id
      t.datetime :current_period_end
      t.datetime :canceled_at

      t.timestamps
    end
  end
end
