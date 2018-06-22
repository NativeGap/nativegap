# frozen_string_literal: true

Rails.application.config.filter_parameters << :password

Raven.configure do |config|
  config.dsn = Rails.env.production? ? Rails.application.credentials.production[:sentry_raven][:dsn] : Rails.application.credentials.development[:sentry_raven][:dsn]
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
