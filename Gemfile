source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) do |repo_name|
    repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
    "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.2'
gem 'puma'
gem 'sass-rails'
gem 'uglifier'
gem 'turbolinks'
gem 'jbuilder'
gem 'redis'
gem 'haml'
gem 'metamagic'
gem 'search-engine-optimization'
gem 'sentry-raven'
gem 'simple_form'
gem 'i18n'
gem 'ahoy_matey'
gem 'cancancan'
gem 'devise'
gem 'bcrypt'
gem 'config'
gem 'sidekiq'
gem 'mailgun-ruby'
gem 'octokit'
gem 'stripe'
gem 'carrierwave'
gem 'carrierwave_backgrounder', github: 'harigopal/carrierwave_backgrounder', branch: 'rails-5-1'
gem 'fog-aws'
gem 'mime-types'
gem 'mini_magick'
gem 'httparty'
gem 'rest-client'
gem 'rubyzip'
gem 'friendly_id'
gem 'foreman'
gem 'turbolinks-animate'
gem 'onsignal'
gem 'nativegap'
gem 'notification-handler'
gem 'notification-pusher-actionmailer'
gem 'notification-pusher-onesignal'
gem 'webpacker'
gem 'r404'
gem 'acts_as_belongable'
gem 'randomize_id'
gem 'cancancan-system'
gem 'mozaic'
gem 'myg'
gem 'nilify_blanks'
gem 'modalist'
gem 'browser'
gem 'pwa'
gem 'git'
gem 'bootsnap', require: false


group :development, :test do
  gem 'byebug'
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  gem 'certified'
  gem 'web-console'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'mysql2', '~> 0.4.10'
end

group :production do
  gem 'pg'
  gem 'rack-timeout'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
