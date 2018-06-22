# frozen_string_literal: true

class AppetizeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'app'

  def perform(build_id)
    build = App::Build.find build_id

    if build.appetize
      HTTParty.delete("https://#{Rails.application.credentials.appetize[:token]}@api.appetize.io/v1/apps/#{build.appetize_public_key}")
      build.update_attributes appetize: nil, appetize_public_key: nil, appetize_private_key: nil
    end

    response = JSON.parse(HTTParty.post("https://#{Rails.application.credentials.appetize[:token]}@api.appetize.io/v1/apps", body: {
      url: build.file.url,
      platform: build.platform
    }.to_json, headers: { 'Content-Type' => 'application/json' }, format: :plain), symbolize_names: true)
    build.update_attributes appetize: response[:publicURL], appetize_public_key: response[:publicKey], appetize_private_key: response[:privateKey]
  end
end
