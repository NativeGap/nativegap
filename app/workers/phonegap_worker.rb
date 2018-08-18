# frozen_string_literal: true

class PhonegapWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false, queue: 'app')

  def perform(build_id:, phonegap_app_id:, phonegap_key_id:)
    build = App::Build.find(build_id)

    phonegap_client = Phonegap::Client.new(
      username: Rails.application.credentials.phonegap[:username],
      password: Rails.application.credentials.phonegap[:password]
    )

    download_build(phonegap_client, phonegap_app_id, build)
    AppetizeWorker.perform_async(build_id: build_id)
    delete_phonegap_app(phonegap_client, phonegap_app_id, phonegap_key_id)
    build.update(status: 'processed')
    build.built_notification
  end

  private

  def download_build(phonegap_client, phonegap_app_id, build)
    phonegap_build = Phonegap::Build.new(phonegap_client,
                                         app_id: phonegap_app_id,
                                         platform: build.platform)
    build.file = phonegap_build.fetch(directory: build.folder_name)
    build.save!
    return_with_error(build) unless build.file.url
  end

  def delete_phonegap_app(phonegap_client, phonegap_app_id, phonegap_key_id)
    Phonegap::App.new(phonegap_client, id: phonegap_app_id).destroy
    "Phonegap::Key::#{build.platform.camelize}".constantize.new(
      phonegap_client,
      id: phonegap_key_id
    ).destroy
  end

  def return_with_error(object)
    object.update_attributes status: 'error'
    exit
  end
end
