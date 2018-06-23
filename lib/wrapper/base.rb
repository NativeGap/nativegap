# frozen_string_literal: true

module Wrapper
  class Base
    attr_accessor :beta

    def initialize(beta: false)
      @beta = beta
    end

    def version
      @beta ? BETA_VERSION : VERSION
    end

    def fetch(directory:)
      Git.clone(github_url, path(directory), branch: github_branch)
      Rails.root.join(path(directory), 'wrapper')
    end

    private

    def github_url
      "https://#{Rails.application.credentials.github[:username]}:"\
      "#{Rails.application.credentials.github[:password]}@github.com/"\
      "#{GITHUB_USERNAME}/#{GITHUB_REPOSITORY}"
    end

    def path(directory)
      "tmp/wrappers/#{directory}"
    end

    def github_branch
      @beta ? :beta : :master
    end
  end
end
