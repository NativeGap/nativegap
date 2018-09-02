# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class App
  class Build < ApplicationRecord
    self.table_name = 'app_builds'

    before_validation :set_wrapper_version
    after_create_commit :build
    after_update_commit :broadcast
    before_destroy :cancel_subscription

    mount_uploader :file, FileUploader
    mount_uploader :icon, IconUploader
    mount_uploader :ios_app_store_icon, AppStoreUploader
    mount_uploader :windows_splash_screen, SplashScreenUploader
    mount_uploader :ios_cert, IosCertUploader
    mount_uploader :ios_profile, IosProfileUploader
    mount_uploader :android_keystore, AndroidKeystoreUploader
    if Rails.env.production?
      process_in_background :icon
      process_in_background :ios_app_store_icon
      process_in_background :windows_splash_screen
    end

    validates :platform, presence: true
    validates :version, presence: true
    validates :wrapper_version, presence: true
    validates :file, integrity: true, processing: true
    validates :icon, integrity: true, processing: true
    validates :windows_splash_screen, integrity: true, processing: true
    validates :ios_cert, integrity: true, processing: true
    validates :ios_profile, integrity: true, processing: true
    validates :android_keystore, integrity: true, processing: true

    has_one :subscription, class_name: '::Subscription'
    belongs_to :app, class_name: '::App'

    delegate :user, to: :app, allow_nil: true

    def folder_name
      id.to_s
    end

    def name
      return "#{I18n.t("d.#{platform}")} (#{I18n.t('d.beta')})" if beta

      I18n.t("d.#{platform}")
    end

    def key_needed?
      return false unless platform == 'ios' && ios_key_needed? ||
                          platform == 'android' && android_key_needed?
      true
    end

    def splash_screen_needed?
      return false unless platform == 'windows' &&
                          windows_splash_screen.url.nil?
      true
    end

    def can_build?
      user.present? && !key_needed? && !splash_screen_needed?
    end

    def start_url
      "#{start_url_without_param}&nativegap=#{platform}" \
        if start_url_without_param.include?('?')
      "#{start_url_without_param}?nativegap=#{platform}"
    end

    def icon_url(version)
      ios_app_store_icon_url(version) || build_icon_url(version) ||
        app_icon_url(version) || splash_screen_url(version)
    end

    def update_available?
      current_wrapper_version = "Wrapper::#{platform.camelize}"
                                .constantize.new(beta: beta).version
      return true unless wrapper_version == current_wrapper_version
      false
    end

    def build
      return unless can_build?

      update_attributes(status: 'processing') unless status == 'processing'
      BuildWorker.perform_in(Settings.nativegap.delay.build, build_id: id)
    end

    def create_appetize
      appetize = Appetize.new.create(
        file_url: file.url,
        platform: platform
      )
      update(
        appetize: appetize.url,
        appetize_public_key: appetize.public_key,
        appetize_private_key: appetize.private_key
      )
    end

    def remove_appetize
      return unless appetize

      Appetize.new(public_key: appetize_public_key).destroy
      update(appetize: nil, appetize_public_key: nil, appetize_private_key: nil)
    end

    def error_network_title
      if subscription&.subscribed? && subscription.plan.end_with?('_pro')
        app.error_network_title
      else
        'Oooooops ...'
      end
    end

    def error_network_content
      if subscription&.subscribed? && subscription.plan.end_with?('_pro')
        app.error_network_content
      else
        'No network connection'
      end
    end

    def error_unsupported_title
      if subscription&.subscribed? && subscription.plan.end_with?('_pro')
        app.error_unsupported_title
      else
        'Oooooops ...'
      end
    end

    def error_unsupported_content
      if subscription&.subscribed? && subscription.plan.end_with?('_pro')
        app.error_unsupported_content
      else
        'Your device is unsupported'
      end
    end

    def built_notification
      return unless user.build_notifications

      notification = user.notify(object: app)
      notification.push(
        :OneSignal,
        player_ids: user.onesignal_player_ids,
        url: Rails.application.routes.url_helpers.app_url(app),
        contents: {
          en: 'App finished processing',
          de: 'Deine App ist fertig!'
        },
        headings: { en: "#{app.name} (#{name})", de: "#{app.name} (#{name})" }
      )
    end

    private

    def ios_key_needed?
      ios_cert.url.nil? || ios_profile.url.nil? || ios_cert_password.nil?
    end

    def android_key_needed?
      android_keystore.url.nil? || android_keystore_password.nil? ||
        android_key_alias.nil? || android_key_password.nil?
    end

    def start_url_without_param
      if path
        app.url.last == '/' ? "#{app.url}#{path}" : "#{app.url}/#{path}"
      else
        app.start_url
      end
    end

    def ios_app_store_icon_url(version)
      return unless platform == 'ios' && version == '_1024x1024'

      ios_app_store_icon.url
    end

    def build_icon_url(version)
      return unless icon.respond_to?(version)

      icon&.send(version)&.url
    end

    def app_icon_url(version)
      return unless app.icon.respond_to?(version)

      app.icon&.send(version)&.url
    end

    def splash_screen_url(version)
      return unless platform == 'windows'

      windows_splash_screen&.send(version)&.url
    end

    def set_wrapper_version
      self.wrapper_version = "Wrapper::#{platform.camelize}"
                             .constantize.new(beta: beta).version
    end

    def cancel_subscription
      return unless subscription.present?

      subscription = Stripe::Subscription.retrieve(
        subscription.stripe_subscription_id
      )
      subscription.delete
    end

    def broadcast
      App::BuildBroadcastWorker.perform_async(id) # if self.status_changed?
    end
  end
end
# rubocop:enable Metrics/ClassLength
