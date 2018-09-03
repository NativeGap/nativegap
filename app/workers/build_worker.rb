# frozen_string_literal: true

class BuildWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false, queue: 'app')

  def perform(build_id)
    build = App::Build.find(build_id)

    case build.platform
    when 'android'
      Build::Andriod.new(build: build).perform
    when 'ios'
      Build::Ios.new(build: build).perform
    when 'windows'
      Build::Windows.new(build: build).perform
    when 'chrome'
      Build::Chrome.new(build: build).perform
    end
  end
end
