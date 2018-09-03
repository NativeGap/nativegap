# frozen_string_literal: true

require 'zip'

module Build
  class Compress < Base
    def perform
      wrapper = builder
      create_zip(wrapper)
      delete_wrapper(wrapper)
      @build.update!(status: 'processed')

      @build.built_notification
    end

    private

    def create_zip(wrapper)
      zip = zip_file_path
      Zip::File.open(zip, Zip::File::CREATE) do |zipfile|
        Dir.glob("#{wrapper}/**/*") do |file|
          zipfile.add(file.sub("#{wrapper}/", ''), file)
        end
      end
      @build.file = File.new(zip)
      @build.save!
      File.delete(zip)
    end

    def zip_file_path
      source_wrappers_path = Rails.root.join('tmp', 'source_wrappers')
      unless File.directory?(source_wrappers_path)
        FileUtils.mkdir_p(source_wrappers_path)
      end

      "#{source_wrappers_path}/#{zip_file_name}"
    end

    def zip_file_name
      "#{@build.folder_name}.zip"
    end
  end
end
