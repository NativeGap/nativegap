# frozen_string_literal: true

module Build
  class Android < Phonegap
    @platform = 'android'

    private

    def create_signing_key
      Phonegap::Key::Android.new(phonegap_client).create(
        keystore: File.new(
          download_file(@build.android_keystore.url, format: 'keystore')
        ),
        keystore_password: @build.android_keystore_password,
        key_password: @build.android_key_password,
        key_alias: @build.android_key_alias,
        title: "#{@build.folder_name} Key"
      )
    end

    def add_signing_key(phonegap_app, phonegap_key)
      phonegap_app.add_android_key(
        id: phonegap_key.id,
        key_password: @build.android_key_password,
        keystore_password: @build.android_keystore_password
      )
    end
  end
end
