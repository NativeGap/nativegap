# frozen_string_literal: true

module Phonegap
  class Build
    FILE_ENDING = {
      android: 'apk',
      ios: 'ipa'
    }

    attr_reader :client, :app_id, :platform

    def initialize(client, app_id:, platform:)
      @client = client
      @app_id = app_id
      @platform = platform
    end

    def fetch(directory:)
      store(directory, download)
    end

    private

    def download
      response = HTTParty.get(
        'https://build.phonegap.com/api/v1/apps/'\
        "#{@app_id}/#{@platform}?auth_token=#{@client.token}",
        format: :plain
      )
      return unless request_successful?(response)
      response.body
    end

    def store(directory, response)
      path = path(directory)
      FileUtils.mkdir_p(path) unless File.directory?(path)
      path = "#{path}.#{FILE_ENDING[@platform.to_sym]}"
      file = File.new(path(directory), 'w')
      file.binmode
      file.write(response)
      file.flush
      file
    end

    def request_successful?(response)
      !JSON.parse(response, symbolize_names: true).key?(:error)
    rescue JSON::ParserError
      false
    end

    def path(directory)
      Rails.root.join('tmp', 'builds', directory)
    end
  end
end
