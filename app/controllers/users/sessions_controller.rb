# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'devise'

  def new
    turbolinks_animate 'fadein'
    super
  end

  def create
    self.resource = warden.authenticate! auth_options
    set_flash_message! :notice, :signed_in
    sign_in resource_name, resource
    if app_param && app_param != ''
      app = App.friendly.find app_param
      app.update! user: current_user unless app.user.present?
      app.builds.each do |build|
        BuildWorker.perform_in Settings.nativegap.delay.build, build.id if build.can_build?
      end
    end
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
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

  def after_sign_in_path_for resource
    apps_url
  end
  def after_sign_out_path_for resource
    root_url
  end
end
