require 'redis'

url = Rails.env.production? ? Rails.application.credentials.production[:redis][:host] : Rails.application.credentials.development[:redis][:host]
password = Rails.env.production? ? Rails.application.credentials.production[:redis][:password] : Rails.application.credentials.development[:redis][:password]

$redis = Redis.new url: url, password: password || nil
