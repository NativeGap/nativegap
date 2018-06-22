# frozen_string_literal: true

class ExploreController < ApplicationController
  before_action :set_app, only: [:show, :install]
  before_action :set_platforms, only: [:show, :install]

  def index
    @apps = App.where(visibility: 'public').order(:created_at)
    authorizes! :read, @apps
    turbolinks_animate 'fadein'
  end

  def show
    authorize! :read, @app
    turbolinks_animate 'fadein'
    render layout: 'mozaic'
  end

  def install
    authorize! :read, @app
    modalist
  end

  private

  def set_app
    @app = App.friendly.find params[:id]
  end
  def set_platforms
    @platforms = []
    if browser.device.mobile?
      return @platforms << :android if browser.platform.android? && @app.android
      return @platforms << :ios if browser.platform.ios? && @app.ios
      return @platforms << :windows if browser.platform.windows_mobile? && @app.windows
    else
      @platforms << :windows if browser.platform.windows10? && @app.windows
      @platforms << :chrome if browser.chrome? && @app.chrome
    end
    if @platforms.length == 0
      @platforms << :android if @app.android
      @platforms << :ios if @app.ios
      @platforms << :windows if @app.windows
      @platforms << :chrome if @app.chrome
    end
  end
end
