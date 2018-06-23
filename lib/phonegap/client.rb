# frozen_string_literal: true

module Phonegap
  class Client
    attr_reader :token

    def initialize(username:, password:)
      @token = fetch_token(username, password)
    end

    private

    def fetch_token(username, password)
      phonegap_auth = { username: username, password: password }
      JSON.parse(
        HTTParty.post(
          'https://build.phonegap.com/token',
          u: username,
          basic_auth: phonegap_auth,
          format: :plain
        ),
        symbolize_names: true
      )[:token]
    end
  end
end
