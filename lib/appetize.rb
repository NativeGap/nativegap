# frozen_string_literal: true

class Appetize
  attr_reader :public_key, :private_key, :url

  def initialize(public_key: nil)
    @public_key = public_key
  end

  def create(file_url:, platform:)
    response = JSON.parse(
      HTTParty.post(
        "https://#{Rails.application.credentials.appetize[:token]}"\
        '@api.appetize.io/v1/apps',
        body: { url: file_url, platform: platform }.to_json,
        headers: { 'Content-Type' => 'application/json' },
        format: :plain
      ),
      symbolize_names: true
    )
    @url = response[:publicURL]
    @public_key = response[:publicKey]
    @private_key = response[:privateKey]
  end

  def destroy
    return unless @public_key
    HTTParty.delete(
      "https://#{Rails.application.credentials.appetize[:token]}"\
      "@api.appetize.io/v1/apps/#{@public_key}"
    )
  end
end
