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
    @app = App.friendly.find(params[:id])
  end

  def set_platforms
    @platforms = detect_app_platforms(app: @app)
  end
end
