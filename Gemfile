# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'

gem 'acts_as_belongable'
gem 'ahoy_matey'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'browser'
gem 'cancancan'
gem 'cancancan-system'
gem 'carrierwave'
gem 'carrierwave_backgrounder', github: 'harigopal/carrierwave_backgrounder',
                                branch: 'rails-5-1'
gem 'config'
gem 'devise'
gem 'fog-aws'
gem 'friendly_id'
gem 'git'
gem 'haml'
gem 'httparty'
gem 'i18n'
gem 'jbuilder'
gem 'mailgun-ruby'
gem 'metamagic'
gem 'mime-types'
gem 'mini_magick'
gem 'modalist'
gem 'mozaic'
gem 'myg'
gem 'nativegap'
gem 'nilify_blanks'
gem 'notification-handler'
gem 'notification-pusher-actionmailer'
gem 'notification-pusher-onesignal'
gem 'octokit'
gem 'onsignal'
gem 'pg'
gem 'puma'
gem 'pwa'
gem 'r404'
gem 'randomize_id'
gem 'redis'
gem 'rest-client'
gem 'rubyzip'
gem 'sass-rails'
gem 'search-engine-optimization'
gem 'sentry-raven'
gem 'sidekiq'
gem 'simple_form'
gem 'skylight'
gem 'stripe'
gem 'turbolinks'
gem 'turbolinks-animate'
gem 'uglifier'
gem 'webpacker'

group :development, :test do
  gem 'byebug'
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'haml-lint', require: false
  gem 'rspec-rails', require: false
  gem 'rspec-sidekiq', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman', require: false
  gem 'pry-rails'
  gem 'web-console'
end

group :production do
  gem 'rack-timeout'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
