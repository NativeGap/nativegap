# frozen_string_literal: true

module Ahoy
  class Store < DatabaseStore
    def exclude?
      bot?
    end
  end
end

# set to true for JavaScript tracking
Ahoy.api = false
