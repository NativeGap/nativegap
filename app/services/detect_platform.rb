# frozen_string_literal: true

class DetectPlatform
  attr_reader :browser, :platforms

  def initialize(browser:)
    @browser = browser
    @platforms = { android: nil, chrome: nil, ios: nil, windows: nil }
  end

  def perform
    if mobile?
      @platforms[:android] = android?
      @platforms[:ios] = ios?
      @platforms[:windows] = windows_mobile?
    else
      @platforms[:chrome] = chrome?
      @platforms[:windows] = windows?
    end
    @platforms
  end

  private

  def mobile?
    @browser.device.mobile?
  end

  def android?
    @browser.platform.android?
  end

  def ios?
    @browser.platform.ios?
  end

  def windows_mobile?
    @browser.platform.windows_mobile?
  end

  def windows?
    @browser.platform.windows10?
  end

  def chrome?
    @browser.chrome?
  end
end
