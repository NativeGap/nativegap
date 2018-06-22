# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
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
    build_resource sign_up_params

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up resource_name, resource
        if app_param && app_param != ''
          app = App.friendly.find app_param
          app.update! user: current_user unless app.user.present?
          app.builds.each do |build|
            BuildWorker.perform_in Settings.nativegap.delay.build, build.id if build.can_build?
          end
        end
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
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
end
