# frozen_string_literal: true

module Wrapper
  class Base
    attr_reader :beta

    def initialize(beta: false)
      @beta = beta
    end

    class << self
      attr_accessor :version, :beta_version, :github_username,
                    :github_repository
    end

    def version
      @beta ? self.class.beta_version : self.class.version
    end

    def fetch(directory:)
      Git.clone(github_url, path(directory), branch: github_branch)
      Rails.root.join(path(directory), 'wrapper')
    end

    private

    def github_url
      "https://#{Rails.application.credentials.github[:username]}:"\
      "#{Rails.application.credentials.github[:password]}@github.com/"\
      "#{self.class.github_username}/#{self.class.github_repository}"
    end

    def path(directory)
      "tmp/wrappers/#{directory}"
    end

    def github_branch
      @beta ? :beta : :master
    end
  end
end
