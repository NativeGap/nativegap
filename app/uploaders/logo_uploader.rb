# frozen_string_literal: true

class LogoUploader < CarrierWave::Uploader::Base
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

  # process :save_content_type_in_model
  # def save_content_type_in_model
  #     model.logo_content_type = file.content_type if file.content_type
  # end

  # # Create different versions of your uploaded files:
  # version :big, if: :image? do
  #     process resize_to_fit: [250, 250]
  # end
  # version :large, from_version: :big, if: :image? do
  #     process resize_to_fit: [90, 90]
  # end
  # version :medium, from_version: :large, if: :image? do
  #     process resize_to_fit: [75, 75]
  # end
  # version :small, from_version: :medium, if: :image? do
  #     process resize_to_fit: [50, 50]
  # end
  # version :tiny, from_version: :small, if: :image? do
  #     process resize_to_fit: [25, 25]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(svg png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # protected
  #
  # def image? new_file
  #     new_file.content_type.start_with?('image') && new_file.content_type.include?('svg') == false
  # end
end
