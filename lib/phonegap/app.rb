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
            data: create_data_hash(title, package, version, description, debug,
                                   private, tag, repository)
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
      HTTParty.delete(app_url)
    end

    def add_android_key(id:, key_password:, keystore_password:)
      HTTParty.put(
        app_url,
        body: {
          data: {
            keys: {
              android: android_key_hash(id, key_password, keystore_password)
            }
          }
        },
        format: :plain
      )
    end

    def add_ios_key(id:, cert_password:)
      HTTParty.put(
        app_url,
        body: { data: { keys: { ios: ios_key_hash(id, cert_password) } } },
        format: :plain
      )
    end

    private

    def create_data_hash(title, package, version, description, debug, private,
                         tag, repository)
      {
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
    end

    def app_url
      'https://build.phonegap.com/api/v1/apps/'\
      "#{@id}?auth_token=#{@client.token}"
    end

    def android_key_hash(id, key_password, keystore_password)
      { id: id, key_pw: key_password, keystore_pw: keystore_password }
    end

    def ios_key_hash(id, cert_password)
      { id: id, password: cert_password }
    end
  end
end
