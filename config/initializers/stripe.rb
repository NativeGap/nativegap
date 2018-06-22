# frozen_string_literal: true

Rails.configuration.stripe = {
  publishable_key: Rails.env.production? ? Rails.application.credentials.production[:stripe][:publishable_key] : Rails.application.credentials.development[:stripe][:publishable_key],
  secret_key: Rails.env.production? ? Rails.application.credentials.production[:stripe][:secret_key] : Rails.application.credentials.development[:stripe][:secret_key]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
