# frozen_string_literal: true

module Phonegap
  class App
    attr_reader :client, :id

    def initialize(client, id: nil)
      @client = client
      @id = id
    end

    def create(title:, package:, version:, description:, debug: false,
               private: false, tag: 'master', repository:)
      @id = JSON.parse(
        HTTParty.post(
          "https://build.phonegap.com/api/v1/apps?auth_token=#{@client.token}",
          body: {
            data: {
              title: title,
              create_method: 'remote_repo',
              package: package,
              version: version,
              description: description,
              debug: debug,
              private: private,
              tag: tag,
              repo: "https://github.com/NativeGap/#{repository}.git"
            }
          },
          format: :plain
        ),
        symbolize_names: true
      )[:id]
    end

    def build
      HTTParty.post(
        'https://build.phonegap.com/api/v1/apps/'\
        "#{@id}/build?auth_token=#{@client.token}"
      )
    end

    def destroy
      return unless @id
      HTTParty.delete(
        'https://build.phonegap.com/api/v1/apps/'\
        "#{@id}?auth_token=#{@client.token}"
      )
    end

    def add_android_key(id:, key_password:, keystore_password:)
      HTTParty.put(
        'https://build.phonegap.com/api/v1/apps/'\
        "#{@id}?auth_token=#{@client.token}",
        body: {
          data: {
            keys: {
              android: {
                id: id,
                key_pw: key_password,
                keystore_pw: keystore_password
              }
            }
          }
        },
        format: :plain
      )
    end

    def add_ios_key(id:, cert_password:)
      HTTParty.put(
        'https://build.phonegap.com/api/v1/apps/'\
        "#{@id}?auth_token=#{@client.token}",
        body: { data: { keys: { ios: { id: id, password: cert_password } } } },
        format: :plain
      )
    end
  end
end
