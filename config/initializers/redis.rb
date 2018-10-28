# frozen_string_literal: true

require 'redis'

url = ENV['REDIS_HOST']
password = ENV['REDIS_PASSWORD']

Redis.new(url: url, password: password)
