# frozen_string_literal: true

module App
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
      app.user.present? && !key_needed? && !splash_screen_needed?
    end

    def start_url
      su =
        if path
          app.url.last == '/' ? "#{app.url}#{path}" : "#{app.url}/#{path}"
        else
          app.start_url
        end
      return su + '&nativegap=' + platform if su.include? '?'
      su + '?nativegap=' + platform
    end

    def icon_url(version)
      if platform == 'ios' && version == '_1024x1024' &&
         !ios_app_store_icon.nil?
        ios_app_store_icon.url
      elsif icon.respond_to?(version)
        icon&.send(version)&.url
      elsif app.icon.respond_to?(version)
        app.icon&.send(version)&.url
      else
        windows_splash_screen&.send(version)&.url
      end
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
      BuildWorker.perform_in(Settings.nativegap.delay.build, id)
    end

    def android_statusbar_background
      self[:android_statusbar_background] || '#000000'
    end

    def android_statusbar_style
      self[:android_statusbar_style] || 'lightcontent'
    end

    def ios_statusbar_style
      self[:ios_statusbar_style] || 'default'
    end

    def chrome_width
      self[:chrome_width] || 350
    end

    def chrome_height
      self[:chrome_height] || 500
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

    private

    def ios_key_needed?
      ios_cert.url.nil? || ios_profile.url.nil? || ios_cert_password.nil?
    end

    def android_key_needed?
      android_keystore.url.nil? || android_keystore_password.nil? ||
        android_key_alias.nil? || android_key_password.nil?
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
      # if self.status_changed?
      App::BuildBroadcastWorker.perform_async(id)
      # end
    end
  end
end
