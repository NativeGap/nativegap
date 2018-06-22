class BuildWorker
    WRAPPER_MAP = {
        'android' => 'jonhue/nativegap-android',
        'ios' => 'jonhue/nativegap-ios',
        'chrome' => 'NativeGap/chrome',
        'windows' => 'NativeGap/windows'
    }

    include Sidekiq::Worker
    sidekiq_options retry: false, queue: 'app'

    def perform build_id
        build = App::Build.find build_id
        octokit_client = Octokit::Client.new login: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password]

        case build.platform
        when 'android', 'ios'
            wrapper = builder build, zip: false
            github build, octokit_client, wrapper
            cleanup build, wrapper

            # Authenticate PhoneGap
            phonegap_auth = { username: Rails.application.credentials.phonegap[:username], password: Rails.application.credentials.phonegap[:password] }
            phonegap_token = JSON.parse(HTTParty.post('https://build.phonegap.com/token', u: Rails.application.credentials.phonegap[:username], basic_auth: phonegap_auth, format: :plain), symbolize_names: true)[:token]

            # Create signing keys
            case build.platform
            when 'android'
                android_keystore = download_file build.android_keystore.url, 'keystore'
                phonegap_android_key_id = JSON.parse(RestClient.post("https://build.phonegap.com/api/v1/keys/android?auth_token=#{phonegap_token}", {
                    title: "#{build.folder_name} Key",
                    alias: build.android_key_alias,
                    key_pw: build.android_key_password,
                    keystore_pw: build.android_keystore_password,
                    keystore: File.new(android_keystore)
                }), symbolize_names: true)[:id]
            when 'ios'
                ios_cert = download_file build.ios_cert.url, 'p12'
                ios_profile = download_file build.ios_profile.url, 'mobileprovision'
                phonegap_ios_key_id = JSON.parse(RestClient.post("https://build.phonegap.com/api/v1/keys/ios?auth_token=#{phonegap_token}", {
                    title: "#{build.folder_name} Key",
                    password: build.ios_cert_password,
                    cert: File.new(ios_cert),
                    profile: File.new(ios_profile)
                }), symbolize_names: true)[:id]
            end

            # Create PhoneGap app
            phonegap_id = JSON.parse(HTTParty.post("https://build.phonegap.com/api/v1/apps?auth_token=#{phonegap_token}", body: { data: {
                title: build.app.name,
                create_method: 'remote_repo',
                package: build.app.package_id,
                version: build.version,
                description: build.app.description,
                debug: false,
                private: false,
                tag: 'master',
                repo: 'https://github.com/NativeGap/' + build.folder_name + '.git'
            } }, format: :plain), symbolize_names: true)[:id]

            # Add signing keys
            case build.platform
            when 'android'
                HTTParty.put("https://build.phonegap.com/api/v1/apps/#{phonegap_id}?auth_token=#{phonegap_token}", body: { data: {
                    keys: {
                        android: {
                            id: phonegap_android_key_id,
                            key_pw: build.android_key_password,
                            keystore_pw: build.android_keystore_password
                        }
                    }
                } }, format: :plain)
            when 'ios'
                HTTParty.put("https://build.phonegap.com/api/v1/apps/#{phonegap_id}?auth_token=#{phonegap_token}", body: { data: {
                    keys: {
                        ios: {
                            id: phonegap_ios_key_id,
                            password: build.ios_cert_password
                        }
                    }
                } }, format: :plain)
            end

            # Delete GitHub repository
            octokit_client.delete_repository 'NativeGap/' + build.folder_name

            # Build PhoneGap app
            HTTParty.post "https://build.phonegap.com/api/v1/apps/#{phonegap_id}/build?auth_token=#{phonegap_token}"
            PhonegapWorker.perform_in Settings.nativegap.delay.phonegap, build_id, phonegap_id, phonegap_android_key_id, phonegap_ios_key_id
        when 'windows', 'chrome'
            wrapper = builder build
            build.update_attributes status: 'processed'
            cleanup build, wrapper

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
    end


    private


    def builder build, options = {}
        defaults = {
            zip: true
        }
        options = defaults.merge! options
        @build = build
        @app = @build.app
        @free = @build.subscription.nil? || !@build.subscription.subscribed?

        wrapper = fetch_wrapper
        if @build.platform == 'windows'
            rename_path wrapper + '/NAME.sln.erb', @app.name_without_spaces # Rename NAME.sln.erb to app name
            rename_path wrapper + '/NAME', @app.name_without_spaces, directory: true # Rename NAME dir to app name
            rename_path wrapper + '/' + @app.name_without_spaces + '/NAME_TemporaryKey.pfx', @app.name_without_spaces # Rename NAME/NAME_TemporaryKey.pfx to app name
            rename_path wrapper + '/' + @app.name_without_spaces + '/NAME.jsproj.erb', @app.name_without_spaces # Rename NAME/NAME.jsproj.erb to app name
        end
        Dir.glob(wrapper + '/**/*') do |path|
            path = path.to_s
            if path.split('.').last == 'erb'
                content = File.read path
                content = ERB.new(content).result binding
                new_path = path.sub('.erb', '')
                File.open(new_path, 'w+') do |f|
                    f.write content
                end
                FileUtils.rm path if File.file? path
            end
            replace_image @build, path
        end
        download_image "#{wrapper}/www/img/logo.#{@app.logo_content_type}", @app.logo.url, @app.logo_content_type != 'svg' if @build.platform == 'android' || @build.platform == 'ios'

        if options[:zip]
            require 'zip'
            zip = Rails.root.join 'tmp', 'source_wrappers', file_name(@build)
            Zip::File.open(zip, Zip::File::CREATE) do |zipfile|
                Dir.glob(wrapper + '/**/*') do |file|
                    zipfile.add file.sub(wrapper + '/', ''), file
                end
            end
            @build.file = File.new zip
            @build.save!
            File.delete zip
        end

        wrapper
    end

    def fetch_wrapper
      clone = Git.clone(
        "https://#{Rails.application.credentials.github[:username]}:#{Rails.application.credentials.github[:password]}@github.com/#{WRAPPER_MAP[@build.platform]}",
        "tmp/wrappers/#{@build.folder_name}",
        branch: @build.beta ? :beta : :master
      )
      clone.instance_variable_get('@working_directory').instance_variable_get('@path') + '/wrapper'
    end

    def cleanup build, wrapper
        FileUtils.remove_dir wrapper
    end

    def github build, octokit_client, wrapper
        begin
            octokit_client.delete_repository "NativeGap/#{build.folder_name}"
        rescue Octokit::UnprocessableEntity
        end
        octokit_client.create_repository build.folder_name, organization: 'NativeGap', private: false, has_issues: false, has_wiki: false, has_downloads: false
        sleep(15)
        Dir.glob(wrapper + '/**/*') do |path|
            next if File.directory? path
            octokit_client.create_contents "NativeGap/#{build.folder_name}", path.sub("#{wrapper}/", ''), '🎉', File.read(path), branch: 'master'
        end
    end

    def file_name build
        "#{build.folder_name}.zip"
    end

    def download_image path, url, image = true
        response = HTTParty.get url
        f = File.new path, 'w'
        f.binmode if image
        f.write response.body
        f.flush if image
        f.close
    end

    def download_file url, format = nil
        response = HTTParty.get url
        f = Tempfile.new (format.nil? ? SecureRandom.hex : [SecureRandom.hex, ".#{format}"])
        f.binmode
        f.write response.body
        f.flush
        f.close
        f
    end

    def replace_image build, path
        case build.platform
        when 'android', 'ios'
            if path.split('.').last == 'png' && path.include?('www/res/icon')
                name = path.split('.').first.split('/')
                version = name.last
                FileUtils.rm path if File.file? path
                download_image path, build.icon_url(version).to_s
            end
        when 'chrome'
            if path.split('.').last == 'png' && (path.include?('app/icons') || path.include?('assets') || path.include?('resources/default_app/icons') || path.include?('data/content/icons'))
                name = path.split('.').first.split('/').last
                case name
                when '128'
                    version = 'large'
                when '64'
                    version = 'medium'
                when '32'
                    version = 'small'
                when '16'
                    version = 'tiny'
                else
                    version = name
                end
                FileUtils.rm path
                download_image path, build.icon_url(version).to_s
            end
        when 'windows'
            if path.split('.').last == 'png' && path.include?('/images/')
                version = path.split('/').last.split('.').first
                FileUtils.rm path
                download_image path, build.icon_url(version).to_s
            end
        end
    end

    def rename_path path, replacement, options = {}
        defaults = {
            directory: false
        }
        options = defaults.merge! options
        if options[:directory]
            FileUtils.mv(path, path.sub('NAME', replacement)) if File.directory? path
        else
            File.rename(path, path.sub('NAME', replacement)) if File.file? path
        end
    end

end
