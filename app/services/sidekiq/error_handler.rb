# frozen_string_literal: true

module Sidekiq
  class ErrorHandler
    def self.process(_error, context)
      build = App::Build.find_by(id: context.dig(:job, 'args', :build_id))
      build&.update!(status: 'error')
    end
  end
end
