# frozen_string_literal: true

module Apps
  class BuildsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_build

    def update
      authorize! :update, @build

      @build.update build_params
      @build.build
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @build.app,
                        notice: I18n.t('apps.builds.update.success')
        end
        format.js { head :ok }
      end
    end

    def version
      modalist
    end

    def key
      modalist
    end

    def splash_screen
      modalist
    end

    private

    def set_build
      @build = App::Build.find params[:id]
    end

    def build_params
      params.fetch(:app_build, {}).permit(
        :path, :version, :beta, :icon, :ios_app_store_icon,
        :windows_splash_screen, :ios_cert, :ios_profile, :ios_cert_password,
        :android_keystore, :android_key_alias, :android_key_password,
        :android_keystore_password, :android_statusbar_background,
        :android_statusbar_style, :ios_statusbar_background,
        :ios_statusbar_style, :windows_tile_background,
        :windows_splash_screen_background, :chrome_width, :chrome_height
      )
    end
  end
end
