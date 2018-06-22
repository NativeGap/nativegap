class PhonegapWorker

    include Sidekiq::Worker
    sidekiq_options retry: false, queue: 'app'

    def perform build_id, phonegap_id, phonegap_android_key_id, phonegap_ios_key_id
        build = App::Build.find build_id

        # Authenticate PhoneGap
        phonegap_auth = { username: Rails.application.credentials.phonegap[:username], password: Rails.application.credentials.phonegap[:password] }
        phonegap_token = JSON.parse(HTTParty.post('https://build.phonegap.com/token', u: Rails.application.credentials.phonegap[:username], basic_auth: phonegap_auth, format: :plain), symbolize_names: true)[:token]

        case build.platform
        when 'ios'
            response = HTTParty.get "https://build.phonegap.com/api/v1/apps/#{phonegap_id}/ios?auth_token=#{phonegap_token}", format: :plain
        when 'android'
            response = HTTParty.get "https://build.phonegap.com/api/v1/apps/#{phonegap_id}/android?auth_token=#{phonegap_token}", format: :plain
        end
        response_valid?(response) ? download_build(build, response) : return_with_error(build)
        return_with_error(build) if build.file.url.nil?

        # Create Appetize app
        AppetizeWorker.perform_async build_id

        # Delete PhoneGap app
        HTTParty.delete("https://build.phonegap.com/api/v1/apps/#{phonegap_id}?auth_token=#{phonegap_token}")
        HTTParty.delete("https://build.phonegap.com/api/v1/keys/ios/#{phonegap_ios_key_id}?auth_token=#{phonegap_token}") unless phonegap_ios_key_id.nil?
        HTTParty.delete("https://build.phonegap.com/api/v1/keys/android/#{phonegap_android_key_id}?auth_token=#{phonegap_token}") unless phonegap_android_key_id.nil?

        build.update_attributes status: 'processed'

        # Send notification
        if build.app.user.build_notifications
            notification = build.app.user.notify object: build.app
            notification.push :OneSignal, player_ids: build.app.user.onesignal_player_ids, url: Rails.application.routes.url_helpers.app_url(build.app), contents: {
                en: 'App finished processing',
                de: 'Deine App ist fertig!'
            }, headings: {
                en: "#{build.app.name} (#{build.name})",
                de: "#{build.app.name} (#{build.name})"
            }
        end
    end


    private


    def download_build build, response
        path = Rails.root.join('tmp', 'builds', build.folder_name).to_s
        FileUtils.mkdir_p path unless File.directory? path
        case build.platform
        when 'ios'
            path += '.ipa'
        when 'android'
            path += '.apk'
        end
        f = File.new path, 'w'
        f.binmode
        f.write response.body
        f.flush
        build.file = f
        build.save!
        f.close
    end

    def response_valid? response
        begin
            !JSON.parse(response, symbolize_names: true).has_key?(:error)
        rescue JSON::ParserError
            true
        end
    end

    def return_with_error object
        object.update_attributes status: 'error'
        exit
    end

end
