# frozen_string_literal: true

module Subscription
  class Invoice < ApplicationRecord
    validates :amount, presence: true

    belongs_to :subscription
  end
end
