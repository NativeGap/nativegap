# frozen_string_literal: true

module App
  class BuildChannel < ApplicationCable::Channel
    def subscribed
      stream_from 'app_build_channel'
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end
end
