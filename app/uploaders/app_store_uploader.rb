# frozen_string_literal: true

class AppStoreUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay

  include CarrierWave::MiniMagick

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fill: [1024, 1024]

  def extension_whitelist
    ['png']
  end
end
