# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    layout 'devise', only: [:new]
    layout 'app', only: [:edit]

    def new
      turbolinks_animate 'fadein'
      super
    end

    def edit
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
            BuildWorker.perform_in(Settings.nativegap.delay.build,
                                   build_id: build.id)
          end
        end
      end
    end

    protected

    def app_param
      sign_up_params = devise_parameter_sanitizer.sanitize :sign_up
      sign_up_params[:app_id]
    end

    def sign_up_params
      sign_up_params = devise_parameter_sanitizer.sanitize :sign_up
      sign_up_params.delete :app_id
      sign_up_params
    end

    def after_sign_up_path_for(_resource)
      apps_url
    end
  end
end
