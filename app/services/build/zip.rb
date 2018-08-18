# frozen_string_literal: true

require 'zip'

module Build
  class Zip < Base
    def perform
      wrapper = builder
      create_zip(wrapper)
      delete_wrapper(wrapper)
      @build.update!(status: 'processed')

      @build.built_notification
    end

    private

    def create_zip(wrapper)
      zip = Rails.root.join('tmp', 'source_wrappers', zip_file_name)
      ::Zip::File.open(zip, ::Zip::File::CREATE) do |zipfile|
        Dir.glob("#{wrapper}/**/*") do |file|
          zipfile.add(file.sub("#{wrapper}/", ''), file)
        end
      end
      @build.file = File.new(zip)
      @build.save!
      File.delete(zip)
    end

    def zip_file_name
      "#{@build.folder_name}.zip"
    end
  end
end
