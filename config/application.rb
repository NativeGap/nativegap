# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NativeGap
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.autoload_paths << Rails.root.join('lib')

    config.i18n.load_path +=
      Dir[Rails.root.join('config', 'locales', '**/*.{rb,yml}').to_s]

    config.action_dispatch.default_headers = { 'X-Frame-Options' => 'ALLOWALL' }

    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
