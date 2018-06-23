# frozen_string_literal: true

module Sidekiq
  class Handler
    def self.process(_error, context)
      build = App::Build.find_by(id: context[:job]['args'][0])
      build.update_attributes(status: 'error') if build.present?
    end
  end
end
