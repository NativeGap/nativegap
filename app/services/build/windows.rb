# frozen_string_literal: true

module Build
  class Windows < Zip
    PLATFORM = 'windows'

    private

    def windows_builder(wrapper, app)
      rename_path(wrapper + '/NAME.sln.erb', app.name_without_spaces)
      rename_path(wrapper + '/NAME', app.name_without_spaces, directory: true)
      rename_path(
        "#{wrapper}/#{app.name_without_spaces}/NAME_TemporaryKey.pfx",
        app.name_without_spaces
      )
      rename_path(
        "#{wrapper}/#{app.name_without_spaces}/NAME.jsproj.erb",
        app.name_without_spaces
      )
    end

    def rename_path(path, replacement, directory: false)
      if directory && File.directory?(path)
        FileUtils.mv(path, path.sub('NAME', replacement))
      elsif File.file?(path)
        File.rename(path, path.sub('NAME', replacement))
      end
    end

    def replace_image(path)
      return unless path.split('.').last == 'png' && path.include?('/images/')

      version = path.split('/').last.split('.').first
      FileUtils.rm(path)
      download_image(path, @build.icon_url(version).to_s)
    end
  end
end
