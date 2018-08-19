# frozen_string_literal: true

class AppsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :new, :create]
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  layout 'app'

  def index
    if current_user
      @apps = current_user.apps.order('updated_at desc')
      authorizes! :read, @apps
      turbolinks_animate 'fadein'
    else
      redirect_to new_user_session_url(nativegap: params[:nativegap])
    end
  end

  def show
    authorize! :read, @app

    @tabs = @app.builds.order(:created_at).map.with_index do |build, index|
      {
        name: build.name,
        id: build.platform,
        partial: 'apps/builds/build',
        partial_locals: { build: build, app: @app },
        active: index.zero?
      }
    end[@tabs.length] = { name: I18n.t('d.settings'), partial: 'settings' }

    turbolinks_animate 'fadein'
  end

  def new
    @app = App.new
    authorize! :create, @app
    turbolinks_animate 'fadein'
  end

  def edit
    authorize! :update, @app
    turbolinks_animate 'fadein'
  end

  def create
    @app = App.new app_params
    authorize! :create, @app
    @app.user = current_user if current_user

    if @app.save
      url = @app.user ? @app : new_user_registration_url(app: @app.slug)
      redirect_to url, notice: I18n.t('apps.create.success'), notify: true
    else
      redirect_to root_url, alert: I18n.t('apps.create.error')
    end
  end

  def update
    authorize! :update, @app

    if @app.update app_params
      redirect_to @app, notice: I18n.t('apps.update.success')
    else
      redirect_to edit_app_url(@app), alert: I18n.t('apps.update.error')
    end
  end

  def destroy
    authorize! :destroy, @app

    if @app.destroy
      redirect_to apps_url, notice: I18n.t('apps.destroy.success')
    else
      redirect_to @app, notice: I18n.t('apps.destroy.error')
    end
  end

  private

  def set_app
    @app = App.friendly.find(params[:id])
  end

  def app_params
    params.require(:app).permit(
      :url, :path, :name, :description, :globalization, :icon, :logo,
      :background, :color, :accent, :statusbar_hide, :orientation_portrait,
      :orientation_portrait_flipped, :orientation_landscape,
      :orientation_landscape_flipped, :splash_screen_background,
      :splash_screen_color, :splash_screen_transition_duration,
      :splash_screen_logo_height, :branding, :splash_screen_loader,
      :error_network_title, :error_network_content, :error_unsupported_title,
      :error_unsupported_content, :one_signal_app_id, :android, :ios, :windows,
      :chrome, :appetize, :ability, :visibility
    )
  end
end
