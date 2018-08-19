# frozen_string_literal: true

class FileUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    "#{model.platform}.#{file.extension}" if original_filename
  end
end
