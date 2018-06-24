# frozen_string_literal: true

module Phonegap
  module Key
    class Ios < Base
      PLATFORM = 'ios'

      def create(profile:, cert:, cert_password:, title:)
        @id = JSON.parse(
          RestClient.post(
            'https://build.phonegap.com/api/v1/keys/ios?auth_token='\
            "#{@client.token}",
            title: title,
            password: cert_password,
            cert: cert,
            profile: profile
          ),
          symbolize_names: true
        )[:id]
      end
    end
  end
end
