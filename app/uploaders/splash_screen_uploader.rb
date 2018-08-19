# frozen_string_literal: true

class SplashScreenUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay

  include CarrierWave::MiniMagick

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fill: [2480, 1200]

  # Windows
  version('_2480x1200') { process resize_to_fit: [2480, 1200] }
  version('_1240x600', from: '_2480x1200') do
    process resize_to_fit: [1240, 600]
  end
  version('_930x450', from: '_1240x600') { process resize_to_fit: [930, 450] }
  version('_775x375', from: '_930x450') { process resize_to_fit: [775, 375] }
  version('_620x300', from: '_775x375') { process resize_to_fit: [620, 300] }
  version('_465x225', from: '_620x300') { process resize_to_fit: [465, 225] }
  version('_388x188', from: '_465x225') { process resize_to_fit: [388, 188] }
  version('_310x150', from: '_388x188') { process resize_to_fit: [310, 150] }

  def extension_whitelist
    ['png']
  end
end
