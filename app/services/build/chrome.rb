# frozen_string_literal: true

module Build
  class Chrome < Zip
    PLATFORM = 'chrome'

    private

    def replace_image(path)
      return unless path.split('.').last == 'png' &&
                    (path.include?('app/icons') ||
                    path.include?('assets') ||
                    path.include?('resources/default_app/icons') ||
                    path.include?('data/content/icons'))

      name = path.split('.').first.split('/').last
      version = image_version(name)
      FileUtils.rm(path)
      download_image(path, @build.icon_url(version).to_s)
    end

    def image_version(name)
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
    end
  end
end
