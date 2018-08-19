# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_current_location, unless: :devise_controller?
  helper_method :current_user
  before_action :set_raven_context
  before_action :set_locale

  include R404Renderer

  rescue_from CanCan::AccessDenied do |exception|
    render_r404 :access_denied, 403, exception
  end

  rescue_from ActiveRecord::RecordNotFound, AbstractController::ActionNotFound,
              ActionController::RoutingError do |exception|
    render_r404 :not_found, 404, exception
  end

  def current_ability
    @current_ability ||= Ability.new current_user
  end

  def authorizes!(ability, collection)
    collection&.select { |object| authorize! ability, object }
  end

  def detect_app_platforms(app:)
    platforms = DetectPlatform.new(browser: browser).perform
    platforms.each do |k, _|
      platforms[k] = false unless app.public_send(k)
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: [:first_name, :last_name, :app_id])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:app_id])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: [:first_name, :last_name,
                                             :publisher_name, :url,
                                             :build_notifications,
                                             :update_notifications,
                                             :visibility])
  end

  private

  def render_r404_access_denied(format, _status, _exception)
    format.html do
      redirect_back fallback_location: root_url,
                    alert: I18n.t('application.unauthorized')
    end
  end

  def set_locale
    I18n.locale = params[:locale] || user_pref_locale || session[:locale] ||
                  user_location_detected_locale || I18n.default_locale

    store_locale
  end

  def user_pref_locale
    return nil unless current_user&.locale
    current_user.locale
  end

  def user_location_detected_locale
    language = browser.accept_language.first
    return nil unless language&.code
    language.code
  end

  def store_locale
    session[:locale] = I18n.locale
    return unless current_user && I18n.locale != current_user.locale
    current_user.locale = I18n.locale
    current_user.save!
  end

  def store_current_location
    store_location_for :user, request.original_url
  end

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context params: params.to_unsafe_h, url: request.url
  end
end
