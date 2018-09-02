# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'devise'

    def new
      turbolinks_animate 'fadein'
      super
    end

    def create
      super do |resource|
        if app_param && app_param != ''
          app = App.friendly.find(app_param)
          app.update!(user: resource) unless app.user.present?
          app.builds.each do |build|
            next unless build.can_build?
            BuildWorker.perform_in(Settings.nativegap.delay.build, build_id: build.id)
          end
        end
      end
    end

    protected

    def app_param
      sign_in_params = devise_parameter_sanitizer.sanitize :sign_in
      sign_in_params[:app_id]
    end

    def sign_in_params
      sign_in_params = devise_parameter_sanitizer.sanitize :sign_in
      sign_in_params.delete :app_id
      sign_in_params
    end

    def after_sign_in_path_for(_resource)
      apps_url
    end

    def after_sign_out_path_for(_resource)
      root_url
    end
  end
end
