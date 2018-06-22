# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Sidekiq.redis { |conn| conn.flushdb } unless Rails.env.production?

unless User.where(email: 'demo@nativegap.com').any?
  demo = User.new(email: 'demo@nativegap.com', password: 'password', first_name: 'Demo', last_name: 'User', locked: true)
  demo.encrypted_password
  demo.skip_confirmation!
  demo.save!
end
