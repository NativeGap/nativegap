# frozen_string_literal: true

fog_directory =
  if Rails.env.production?
    Rails.application.credentials.production[:digital_ocean][:space]
  else
    Rails.application.credentials.development[:digital_ocean][:space]
  end
asset_host = "https://#{config.fog_directory}.nyc3.digitaloceanspaces.com"

CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: Rails.application.credentials.digital_ocean[:key],
    aws_secret_access_key: Rails.application.credentials.digital_ocean[:access],
    region: 'nyc3',
    endpoint: 'https://nyc3.digitaloceanspaces.com'
  }
  config.fog_directory = fog_directory
  config.asset_host = asset_host
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
