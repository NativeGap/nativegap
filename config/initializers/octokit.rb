# frozen_string_literal: true

Octokit.configure do |c|
  c.login = Rails.application.credentials.github[:username]
  c.password = Rails.application.credentials.github[:password]
end
