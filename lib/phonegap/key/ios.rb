# frozen_string_literal: true

module Phonegap
  module Key
    class Ios < Base
      @platform = 'ios'

      def create(profile:, cert:, cert_password:, title:)
        @id = JSON.parse(
          create_request(profile, cert, cert_password, title),
          symbolize_names: true
        )[:id]
      end

      private

      def create_request(profile, cert, cert_password, title)
        RestClient.post(
          "https://build.phonegap.com/api/v1/keys/#{self.class.platform}"\
          "?auth_token=#{@client.token}",
          title: title,
          password: cert_password,
          cert: cert,
          profile: profile
        )
      end
    end
  end
end
