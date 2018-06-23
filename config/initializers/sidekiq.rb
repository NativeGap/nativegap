# frozen_string_literal: true

# => http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/

error_handler = proc { |e, context| Sidekiq::ErrorHandler.process(e, context) }

if Rails.env.production?
  host = Rails.application.credentials.production[:redis][:host]
  password = Rails.application.credentials.production[:redis][:password]

  Sidekiq.configure_client do |config|
    config.redis = { url: host, password: password, size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: host, password: password, size: 24 }
    config.error_handlers << error_handler
  end
elsif Rails.env.development?
  host = Rails.application.credentials.development[:redis][:host]

  Sidekiq.configure_client do |config|
    config.redis = { url: host, size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: host, size: 49 }
    config.error_handlers << error_handler
  end
end
