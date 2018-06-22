class App::BuildChannel < ApplicationCable::Channel

    def subscribed
        stream_from "app_build_channel"
    end

    def unsubscribed
        # Any cleanup needed when channel is unsubscribed
    end

end
