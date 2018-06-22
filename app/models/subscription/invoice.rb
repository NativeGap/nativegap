# frozen_string_literal: true

class Subscription::Invoice < ApplicationRecord
  validates :amount, presence: true

  belongs_to :subscription
end
