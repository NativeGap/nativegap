# frozen_string_literal: true

# => http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: Rails.application.credentials.production[:redis][:host], password: Rails.application.credentials.production[:redis][:password], size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: Rails.application.credentials.production[:redis][:host], password: Rails.application.credentials.production[:redis][:password], size: 24 }
    config.error_handlers << Proc.new { |e, context| ::BuildError.process(e, context) }
  end
elsif Rails.env.development?
  Sidekiq.configure_client do |config|
    config.redis = { url: Rails.application.credentials.development[:redis][:host], size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: Rails.application.credentials.development[:redis][:host], size: 49 }
    config.error_handlers << Proc.new { |e, context| ::BuildError.process(e, context) }
  end
end
