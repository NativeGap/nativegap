# frozen_string_literal: true

## Load the subfolders in the locales
load_path = Rails.root.join('config', 'locales', '**', '*.{rb,yml}')
Rails.application.config.i18n.load_path += Dir[load_path]

## Set default locale
Rails.application.config.i18n.default_locale = 'en'

## Provide locale fallbacks
Rails.application.config.i18n.enforce_available_locales = false
Rails.application.config.i18n.fallbacks = {
  'en-au': :en, 'en-bz': :en, 'en-ca': :en, 'en-cb': :en, 'en-gb': :en,
  'en-ie': :en, 'en-in': :en, 'en-jm': :en, 'en-nz': :en, 'en-ph': :en,
  'en-us': :en, 'en-tt': :en, 'en-za': :en,
  'de-at': :de, 'de-ch': :de, 'de-de': :de, 'de-li': :de, 'de-lu': :de
}
