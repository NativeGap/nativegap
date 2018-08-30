# frozen_string_literal: true

module Build
  class Ios < Phonegap
    @platform = 'ios'

    private

    def create_signing_key
      Phonegap::Key::Ios.new(phonegap_client).create(
        profile: File.new(
          download_file(@build.ios_profile.url, format: 'mobileprovision')
        ),
        cert: File.new(download_file(@build.ios_cert.url, format: 'p12')),
        cert_password: @build.ios_cert_password,
        title: "#{@build.folder_name} Key"
      )
    end

    def add_signing_key(phonegap_app, phonegap_key)
      phonegap_app.add_ios_key(
        id: phonegap_key.id,
        cert_password: @build.ios_cert_password
      )
    end
  end
end
