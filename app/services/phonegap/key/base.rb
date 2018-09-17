# frozen_string_literal: true

module Phonegap
  module Key
    class Base
      attr_reader :client, :id

      def initialize(client, id: nil)
        @client = client
        @id = id
      end

      class << self
        attr_accessor :platform
      end

      def destroy
        return unless @id

        HTTParty.delete(
          "https://build.phonegap.com/api/v1/keys/#{self.class.platform}/"\
          "#{@id}?auth_token=#{@client.token}"
        )
      end
    end
  end
end
