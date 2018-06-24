# frozen_string_literal: true

module Phonegap
  module Key
    class Android < Base
      PLATFORM = 'android'

      def create(keystore:, keystore_password:, key_password:, key_alias:,
                 title:)
        @id = JSON.parse(
          RestClient.post(
            'https://build.phonegap.com/api/v1/keys/android?auth_token='\
            "#{@client.token}",
            title: title,
            alias: key_alias,
            key_pw: key_password,
            keystore_pw: keystore_password,
            keystore: keystore
          ),
          symbolize_names: true
        )[:id]
      end
    end
  end
end
