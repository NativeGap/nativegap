# frozen_string_literal: true

publishable_key =
  if Rails.env.production?
    Rails.application.credentials.production[:stripe][:publishable_key]
  else
    Rails.application.credentials.development[:stripe][:publishable_key]
  end
secret_key =
  if Rails.env.production?
    Rails.application.credentials.production[:stripe][:secret_key]
  else
    Rails.application.credentials.development[:stripe][:secret_key]
  end

Rails.configuration.stripe = {
  publishable_key: publishable_key,
  secret_key: secret_key
}

Stripe.api_key = secret_key
