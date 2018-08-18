# frozen_string_literal: true

module Build
  class Phonegap < Base
    def perform
      wrapper = builder
      github(wrapper)
      delete_wrapper(wrapper)

      phonegap_key = create_signing_key
      phonegap_app = create_phonegap_app
      add_signing_key(phonegap_app, phonegap_key)

      delete_github_repository

      build_phonegap_app(phonegap_app, phonegap_key)
    end

    private

    def github(wrapper)
      delete_github_reposirory
      create_github_repository

      Dir.glob("#{wrapper}/**/*") do |path|
        next if File.directory?(path)
        octokit_client.create_contents("NativeGap/#{@build.folder_name}",
                                       path.sub("#{wrapper}/", ''), '🎉',
                                       File.read(path), branch: 'master')
      end
    end

    def github_delete_reposirory
      octokit_client.delete_repository("NativeGap/#{@build.folder_name}")
    rescue Octokit::UnprocessableEntity
      p 'Repository already exists'
    end

    def github_create_repository
      octokit_client.create_repository(
        @build.folder_name,
        organization: 'NativeGap',
        private: true,
        has_issues: false,
        has_wiki: false,
        has_downloads: false
      )
    end

    def phonegap_builder(wrapper, app)
      download_image(
        "#{wrapper}/www/img/logo.#{app.logo_content_type}",
        app.logo.url,
        binary: app.logo_content_type != 'svg'
      )
    end

    def create_phonegap_app
      Phonegap::App.new(phonegap_client).create(
        title: @build.app.name,
        package: @build.app.package_id,
        version: @build.version,
        description: @build.app.description,
        repository: @build.folder_name
      )
    end

    def delete_github_repository
      octokit_client.delete_repository("NativeGap/#{@build.folder_name}")
    end

    def build_phonegap_app(phonegap_app, phonegap_key)
      phonegap_app.build
      PhonegapWorker.perform_in(
        Settings.nativegap.delay.phonegap,
        build_id: @build.id,
        phonegap_app_id: phonegap_app.id,
        phonegap_key_id: phonegap_key.id
      )
    end

    def download_file(url, format: nil)
      response = HTTParty.get(url)
      filename =
        format.nil? ? SecureRandom.hex : [SecureRandom.hex, ".#{format}"]

      f = Tempfile.new(filename)
      f.binmode
      f.write(response.body)
      f.flush
      f.close
      f
    end

    def replace_image(path)
      return unless path.split('.').last == 'png' &&
                    path.include?('www/res/icon')

      name = path.split('.').first.split('/')
      version = name.last
      FileUtils.rm(path) if File.file?(path)
      download_image(path, @build.icon_url(version).to_s)
    end

    def phonegap_client
      @phonegap_client ||= Phonegap::Client.new(
        username: Rails.application.credentials.phonegap[:username],
        password: Rails.application.credentials.phonegap[:password]
      )
    end

    def octokit_client
      @octokit_client ||= Octokit::Client.new(
        login: Rails.application.credentials.github[:username],
        password: Rails.application.credentials.github[:password]
      )
    end
  end
end
