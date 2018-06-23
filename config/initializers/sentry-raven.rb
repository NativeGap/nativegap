# frozen_string_literal: true

dsn =
  if Rails.env.production?
    Rails.application.credentials.production[:sentry_raven][:dsn]
  else
    Rails.application.credentials.development[:sentry_raven][:dsn]
  end
sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)

Raven.configure do |config|
  config.dsn = dsn
  config.sanitize_fields = sanitize_fields
end
