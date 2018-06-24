# frozen_string_literal: true

class BuildWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false, queue: 'app')

  def perform(build_id:)
    build = App::Build.find(build_id)
    octokit_client = Octokit::Client.new(
      login: Rails.application.credentials.github[:username],
      password: Rails.application.credentials.github[:password]
    )

    case build.platform
    when 'android', 'ios'
      wrapper = builder build, zip: false
      github build, octokit_client, wrapper
      cleanup(wrapper)

      phonegap_client = Phonegap::Client.new(
        username: Rails.application.credentials.phonegap[:username],
        password: Rails.application.credentials.phonegap[:password]
      )

      # Create signing keys
      case build.platform
      when 'android'
        phonegap_key = Phonegap::Key::Android.new(phonegap_client).create(
          keystore: File.new(download_file(build.android_keystore.url, 'keystore')),
          keystore_password: build.android_keystore_password,
          key_password: build.android_key_password,
          key_alias: build.android_key_alias,
          title: "#{build.folder_name} Key"
        )
      when 'ios'
        phonegap_key = Phonegap::Key::Ios.new(phonegap_client).create(
          profile: File.new(download_file(build.ios_profile.url, 'mobileprovision')),
          cert: File.new(download_file(build.ios_cert.url, 'p12')),
          cert_password: build.ios_cert_password,
          title: "#{build.folder_name} Key"
        )
      end

      # Create PhoneGap app
      phonegap_app = Phonegap::App.new(phonegap_client)
                     .create(
                       title: build.app.name,
                       package: build.app.package_id,
                       version: build.version,
                       description: build.app.description,
                       repository: build.folder_name
                     )

      # Add signing keys
      case build.platform
      when 'android'
        phonegap_app.add_android_key(
          id: phonegap_key.id,
          key_password: build.android_key_password,
          keystore_password: build.android_keystore_password
        )
      when 'ios'
        phonegap_app.add_ios_key(
          id: phonegap_key.id,
          cert_password: build.ios_cert_password
        )
      end

      # Delete GitHub repository
      octokit_client.delete_repository("NativeGap/#{build.folder_name}")

      # Build PhoneGap app
      phonegap_app.build
      PhonegapWorker.perform_in(
        Settings.nativegap.delay.phonegap,
        build_id: build.id,
        phonegap_app_id: phonegap_app.id,
        phonegap_key_id: phonegap_key.id
      )
    when 'windows', 'chrome'
      wrapper = builder build
      build.update_attributes status: 'processed'
      cleanup(wrapper)

      # Send notification
      if build.app.user.build_notifications
        notification = build.app.user.notify object: build.app
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
  end

  private

  def builder(build, options = {})
    defaults = {
      zip: true
    }
    options = defaults.merge! options
    @build = build
    @app = @build.app
    @free = @build.subscription.nil? || !@build.subscription.subscribed?

    wrapper = "Wrapper::#{@build.platform}.camelize"
              .constantize.new(@build.beta).fetch(directory: @build.folder_name)
    if @build.platform == 'windows'
      # Rename NAME.sln.erb to app name
      rename_path(wrapper + '/NAME.sln.erb', @app.name_without_spaces)
      # Rename NAME dir to app name
      rename_path(wrapper + '/NAME', @app.name_without_spaces, directory: true)
      # Rename NAME/NAME_TemporaryKey.pfx to app name
      rename_path(
        wrapper + '/' + @app.name_without_spaces + '/NAME_TemporaryKey.pfx',
        @app.name_without_spaces
      )
      # Rename NAME/NAME.jsproj.erb to app name
      rename_path(
        wrapper + '/' + @app.name_without_spaces + '/NAME.jsproj.erb',
        @app.name_without_spaces
      )
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
    if @build.platform == 'android' || @build.platform == 'ios'
      download_image(
        "#{wrapper}/www/img/logo.#{@app.logo_content_type}",
        @app.logo.url,
        @app.logo_content_type != 'svg'
      )
    end

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

  def cleanup(wrapper)
    FileUtils.remove_dir wrapper
  end

  def github(build, octokit_client, wrapper)
    begin
      octokit_client.delete_repository "NativeGap/#{build.folder_name}"
    rescue Octokit::UnprocessableEntity
      p 'Repository already exists'
    end
    octokit_client.create_repository(
      build.folder_name,
      organization: 'NativeGap',
      private: false,
      has_issues: false,
      has_wiki: false,
      has_downloads: false
    )
    sleep(15)
    Dir.glob(wrapper + '/**/*') do |path|
      next if File.directory? path
      octokit_client.create_contents(
        "NativeGap/#{build.folder_name}",
        path.sub("#{wrapper}/", ''),
        '🎉',
        File.read(path),
        branch: 'master'
      )
    end
  end

  def file_name(build)
    "#{build.folder_name}.zip"
  end

  def download_image(path, url, image = true)
    response = HTTParty.get url
    f = File.new path, 'w'
    f.binmode if image
    f.write response.body
    f.flush if image
    f.close
  end

  def download_file(url, format = nil)
    response = HTTParty.get url
    filename = format.nil? ? SecureRandom.hex : [SecureRandom.hex, ".#{format}"]
    f = Tempfile.new(filename)
    f.binmode
    f.write response.body
    f.flush
    f.close
    f
  end

  def replace_image(build, path)
    case build.platform
    when 'android', 'ios'
      if path.split('.').last == 'png' && path.include?('www/res/icon')
        name = path.split('.').first.split('/')
        version = name.last
        FileUtils.rm path if File.file? path
        download_image path, build.icon_url(version).to_s
      end
    when 'chrome'
      if path.split('.').last == 'png' && (path.include?('app/icons') ||
         path.include?('assets') ||
         path.include?('resources/default_app/icons') ||
         path.include?('data/content/icons'))
        name = path.split('.').first.split('/').last
        version =
          case name
          when '128'
            'large'
          when '64'
            'medium'
          when '32'
            'small'
          when '16'
            'tiny'
          else
            name
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

  def rename_path(path, replacement, options = {})
    defaults = {
      directory: false
    }
    options = defaults.merge! options
    if options[:directory] && File.directory?(path)
      FileUtils.mv(path, path.sub('NAME', replacement))
    elsif File.file?(path)
      File.rename(path, path.sub('NAME', replacement))
    end
  end
end
