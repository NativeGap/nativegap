# frozen_string_literal: true

module Sidekiq
  class ErrorHandler
    def self.process(_error, context)
      build = App::Build.find_by(id: context[:job]['args'][0])
      build&.update_attributes(status: 'error')
    end
  end
end
