# frozen_string_literal: true

class IconUploader < CarrierWave::Uploader::Base
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
  #   # ActionController::Base.helpers.asset_path(
  #   #   "fallback/" + [version_name, "default.png"].compact.join('_')
  #   # )
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:

  process resize_to_fill: [1240, 1240]

  ## Android
  version :xxxhdpi do
    process resize_to_fill: [192, 192]
  end
  version :xxhdpi, from: :xxxhdpi do
    process resize_to_fill: [144, 144]
  end
  version :xhdpi, from: :xxhdpi do
    process resize_to_fill: [96, 96]
  end
  version :hdpi, from: :xhdpi do
    process resize_to_fill: [72, 72]
  end
  version :mdpi, from: :hdpi do
    process resize_to_fill: [48, 48]
  end
  version :ldpi, from: :mdpi do
    process resize_to_fill: [36, 36]
  end

  ## iOS
  version '_1024x1024' do
    process resize_to_fill: [1024, 1024]
  end
  version '_180x180', from: '_1024x1024' do
    process resize_to_fill: [180, 180]
  end
  version '_167x167', from: '_180x180' do
    process resize_to_fill: [167, 167]
  end
  version '_152x152', from: '_167x167' do
    process resize_to_fill: [152, 152]
  end
  version '_120x120', from: '_152x152' do
    process resize_to_fill: [120, 120]
  end
  version '_87x87', from: '_120x120' do
    process resize_to_fill: [87, 87]
  end
  version '_80x80', from: '_87x87' do
    process resize_to_fill: [80, 80]
  end
  version '_76x76', from: '_80x80' do
    process resize_to_fill: [76, 76]
  end
  version '_60x60', from: '_80x80' do
    process resize_to_fill: [60, 60]
  end
  version '_58x58', from: '_60x60' do
    process resize_to_fill: [58, 58]
  end
  version '_40x40', from: '_58x58' do
    process resize_to_fill: [40, 40]
  end

  ## Windows
  version '_1240x1240' do
    process resize_to_fill: [1240, 1240]
  end
  version '_620x620', from: '_1240x1240' do
    process resize_to_fill: [620, 620]
  end
  version '_600x600', from: '_620x620' do
    process resize_to_fill: [600, 600]
  end
  version '_465x465', from: '_600x600' do
    process resize_to_fill: [465, 465]
  end
  version '_388x388', from: '_465x465' do
    process resize_to_fill: [388, 388]
  end
  version '_310x310', from: '_388x388' do
    process resize_to_fill: [310, 310]
  end
  version '_300x300', from: '_310x310' do
    process resize_to_fill: [300, 300]
  end
  version '_284x284', from: '_300x300' do
    process resize_to_fill: [284, 284]
  end
  version '_256x256', from: '_284x284' do
    process resize_to_fill: [256, 256]
  end
  version '_225x225', from: '_256x256' do
    process resize_to_fill: [225, 225]
  end
  version '_188x188', from: '_225x225' do
    process resize_to_fill: [188, 188]
  end
  version '_176x176', from: '_188x188' do
    process resize_to_fill: [176, 176]
  end
  version '_150x150', from: '_176x176' do
    process resize_to_fill: [150, 150]
  end
  version '_142x142', from: '_150x150' do
    process resize_to_fill: [142, 142]
  end
  version '_107x107', from: '_142x142' do
    process resize_to_fill: [107, 107]
  end
  version '_96x96', from: '_107x107' do
    process resize_to_fill: [96, 96]
  end
  version '_89x89', from: '_96x96' do
    process resize_to_fill: [89, 89]
  end
  version '_88x88', from: '_89x89' do
    process resize_to_fill: [88, 88]
  end
  version '_71x71', from: '_88x88' do
    process resize_to_fill: [71, 71]
  end
  version '_66x66', from: '_71x71' do
    process resize_to_fill: [66, 66]
  end
  version '_55x55', from: '_66x66' do
    process resize_to_fill: [55, 55]
  end
  version '_50x50', from: '_55x55' do
    process resize_to_fill: [50, 50]
  end
  version '_48x48', from: '_50x50' do
    process resize_to_fill: [48, 48]
  end
  version '_44x44', from: '_48x48' do
    process resize_to_fill: [44, 44]
  end
  version '_36x36', from: '_44x44' do
    process resize_to_fill: [36, 36]
  end
  version '_32x32', from: '_36x36' do
    process resize_to_fill: [32, 32]
  end
  version '_30x30', from: '_32x32' do
    process resize_to_fill: [30, 30]
  end
  version '_24x24', from: '_30x30' do
    process resize_to_fill: [24, 24]
  end
  version '_16x16', from: '_24x24' do
    process resize_to_fill: [16, 16]
  end

  ## Chrome
  version :logo do
    process resize_to_fill: [500, 500]
  end
  version :large, from: :logo do
    process resize_to_fill: [128, 128]
  end
  version :medium, from: :large do
    process resize_to_fill: [64, 64]
  end
  version :small, from: :medium do
    process resize_to_fill: [32, 32]
  end
  version :tiny, from: :small do
    process resize_to_fill: [16, 16]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[png]
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for
  # details.
  def filename
    if version_name == :icns
      "#{original_filename.split('.').first}.icns"
    else
      original_filename
    end
  end
end
