# frozen_string_literal: true

module Build
  class Base
    attr_reader :build

    def initialize(build:)
      @build = build
    end

    class << self
      attr_accessor :platform
    end

    private

    def builder
      @app = @build.app
      @free = free?

      wrapper = wrapper_class.constantize.new(beta: @build.beta)
                             .fetch(directory: @build.folder_name)
      fill_templates(wrapper)

      case self.class.platform
      when 'android', 'ios'
        phonegap_builder(wrapper, @app)
      when 'windows'
        windows_builder(wrapper, @app)
      end

      wrapper
    end

    def delete_wrapper(wrapper)
      FileUtils.remove_dir(wrapper)
    end

    def fill_templates(wrapper)
      Dir.glob("#{wrapper}/**/*") do |path|
        path = path.to_s

        if path.split('.').last == 'erb'
          content = File.read(path)
          content = ERB.new(content).result(binding)
          new_path = path.sub('.erb', '')
          File.open(new_path, 'w+') { |f| f.write(content) }
          FileUtils.rm(path) if File.file?(path)
        end

        replace_image(path)
      end
    end

    def download_image(path, url, binary: true)
      response = HTTParty.get(url)

      f = File.new(path, 'w')
      f.binmode if binary
      f.write(response.body)
      f.flush if binary
      f.close
    end

    def wrapper_class
      "Wrapper::#{self.class.platform.camelize}"
    end

    def free?
      !@build.subscription&.subscribed?
    end
  end
end
