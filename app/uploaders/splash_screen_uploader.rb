# frozen_string_literal: true

class SplashScreenUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:

  process resize_to_fill: [2480, 1200]

  ## Windows
  version '_2480x1200' do
    process resize_to_fit: [2480, 1200]
  end
  version '_1240x600', from: '_2480x1200' do
    process resize_to_fit: [1240, 600]
  end
  version '_930x450', from: '_1240x600' do
    process resize_to_fit: [930, 450]
  end
  version '_775x375', from: '_930x450' do
    process resize_to_fit: [775, 375]
  end
  version '_620x300', from: '_775x375' do
    process resize_to_fit: [620, 300]
  end
  version '_465x225', from: '_620x300' do
    process resize_to_fit: [465, 225]
  end
  version '_388x188', from: '_465x225' do
    process resize_to_fit: [388, 188]
  end
  version '_310x150', from: '_388x188' do
    process resize_to_fit: [310, 150]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
