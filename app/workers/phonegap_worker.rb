# frozen_string_literal: true

class PhonegapWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false, queue: 'app')

  def perform(build_id, phonegap_app_id, phonegap_key_id)
    build = App::Build.find(build_id)

    phonegap_client = Phonegap::Client.new(
      username: Rails.application.credentials.phonegap[:username],
      password: Rails.application.credentials.phonegap[:password]
    )

    # Download build
    phonegap_build = Phonegap::Build.new(phonegap_client,
                                         app_id: phonegap_app_id,
                                         platform: build.platform
                                        )
    build.file = phonegap.fetch(directory: build.folder_name)
    build.save!
    return_with_error(build) unless build.file.url

    # Create Appetize app
    AppetizeWorker.perform_async build_id

    # Delete PhoneGap app
    Phonegap::App.new(phonegap_client, id: phonegap_app_id).destroy
    "Phonegap::Key::#{build.platform.camelize}".constantize.new(
      phonegap_client,
      id: phonegap_key_id
    ).destroy

    build.update(status: 'processed')

    # Send notification
    send_notification(build) if build.app.user.build_notifications
  end

  private

  def return_with_error(object)
    object.update_attributes status: 'error'
    exit
  end

  def send_notification(build)
    notification = build.app.user.notify(object: build.app)
    notification.push(
      :OneSignal,
      player_ids: build.app.user.onesignal_player_ids,
      url: Rails.application.routes.url_helpers.app_url(build.app),
      contents: {
        en: 'App finished processing',
        de: 'Deine App ist fertig!'
      }, headings: {
        en: "#{build.app.name} (#{build.name})",
        de: "#{build.app.name} (#{build.name})"
      }
    )
  end
end
