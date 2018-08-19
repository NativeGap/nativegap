# frozen_string_literal: true

class IconUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay

  include CarrierWave::MiniMagick

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fill: [1240, 1240]

  # Android
  version(:xxxhdpi) { process resize_to_fill: [192, 192] }
  version(:xxhdpi, from: :xxxhdpi) { process resize_to_fill: [144, 144] }
  version(:xhdpi, from: :xxhdpi) { process resize_to_fill: [96, 96] }
  version(:hdpi, from: :xhdpi) { process resize_to_fill: [72, 72] }
  version(:mdpi, from: :hdpi) { process resize_to_fill: [48, 48] }
  version(:ldpi, from: :mdpi) { process resize_to_fill: [36, 36] }

  # iOS
  version('_1024x1024') { process resize_to_fill: [1024, 1024] }
  version('_180x180', from: '_1024x1024') { process resize_to_fill: [180, 180] }
  version('_167x167', from: '_180x180') { process resize_to_fill: [167, 167] }
  version('_152x152', from: '_167x167') { process resize_to_fill: [152, 152] }
  version('_120x120', from: '_152x152') { process resize_to_fill: [120, 120] }
  version('_87x87', from: '_120x120') { process resize_to_fill: [87, 87] }
  version('_80x80', from: '_87x87') { process resize_to_fill: [80, 80] }
  version('_76x76', from: '_80x80') { process resize_to_fill: [76, 76] }
  version('_60x60', from: '_80x80') { process resize_to_fill: [60, 60] }
  version('_58x58', from: '_60x60') { process resize_to_fill: [58, 58] }
  version('_40x40', from: '_58x58') { process resize_to_fill: [40, 40] }

  # Windows
  version('_1240x1240') { process resize_to_fill: [1240, 1240] }
  version('_620x620', from: '_1240x1240') { process resize_to_fill: [620, 620] }
  version('_600x600', from: '_620x620') { process resize_to_fill: [600, 600] }
  version('_465x465', from: '_600x600') { process resize_to_fill: [465, 465] }
  version('_388x388', from: '_465x465') { process resize_to_fill: [388, 388] }
  version('_310x310', from: '_388x388') { process resize_to_fill: [310, 310] }
  version('_300x300', from: '_310x310') { process resize_to_fill: [300, 300] }
  version('_284x284', from: '_300x300') { process resize_to_fill: [284, 284] }
  version('_256x256', from: '_284x284') { process resize_to_fill: [256, 256] }
  version('_225x225', from: '_256x256') { process resize_to_fill: [225, 225] }
  version('_188x188', from: '_225x225') { process resize_to_fill: [188, 188] }
  version('_176x176', from: '_188x188') { process resize_to_fill: [176, 176] }
  version('_150x150', from: '_176x176') { process resize_to_fill: [150, 150] }
  version('_142x142', from: '_150x150') { process resize_to_fill: [142, 142] }
  version('_107x107', from: '_142x142') { process resize_to_fill: [107, 107] }
  version('_96x96', from: '_107x107') { process resize_to_fill: [96, 96] }
  version('_89x89', from: '_96x96') { process resize_to_fill: [89, 89] }
  version('_88x88', from: '_89x89') { process resize_to_fill: [88, 88] }
  version('_71x71', from: '_88x88') { process resize_to_fill: [71, 71] }
  version('_66x66', from: '_71x71') { process resize_to_fill: [66, 66] }
  version('_55x55', from: '_66x66') { process resize_to_fill: [55, 55] }
  version('_50x50', from: '_55x55') { process resize_to_fill: [50, 50] }
  version('_48x48', from: '_50x50') { process resize_to_fill: [48, 48] }
  version('_44x44', from: '_48x48') { process resize_to_fill: [44, 44] }
  version('_36x36', from: '_44x44') { process resize_to_fill: [36, 36] }
  version('_32x32', from: '_36x36') { process resize_to_fill: [32, 32] }
  version('_30x30', from: '_32x32') { process resize_to_fill: [30, 30] }
  version('_24x24', from: '_30x30') { process resize_to_fill: [24, 24] }
  version('_16x16', from: '_24x24') { process resize_to_fill: [16, 16] }

  # Chrome
  version(:logo) { process resize_to_fill: [500, 500] }
  version(:large, from: :logo) { process resize_to_fill: [128, 128] }
  version(:medium, from: :large) { process resize_to_fill: [64, 64] }
  version(:small, from: :medium) { process resize_to_fill: [32, 32] }
  version(:tiny, from: :small) { process resize_to_fill: [16, 16] }

  def extension_whitelist
    ['png']
  end

  def filename
    if version_name == :icns
      "#{original_filename.split('.').first}.icns"
    else
      original_filename
    end
  end
end
