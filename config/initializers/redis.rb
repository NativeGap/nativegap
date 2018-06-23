# frozen_string_literal: true

require 'redis'

url =
  if Rails.env.production?
    Rails.application.credentials.production[:redis][:host]
  else
    Rails.application.credentials.development[:redis][:host]
  end
password =
  if Rails.env.production?
    Rails.application.credentials.production[:redis][:password]
  else
    Rails.application.credentials.development[:redis][:password]
  end

Redis.new(url: url, password: password)
