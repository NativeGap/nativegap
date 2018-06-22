class App::Build < ApplicationRecord

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
        "#{self.id}"
    end
    def name
        return "#{I18n.t("d.#{self.platform}")} (#{I18n.t('d.beta')})" if self.beta
        I18n.t("d.#{self.platform}")
    end
    def key_needed?
        return true if (self.platform == 'ios' && (self.ios_cert.url.nil? || self.ios_profile.url.nil? || self.ios_cert_password.nil?)) || (self.platform == 'android' && (self.android_keystore.url.nil? || self.android_keystore_password.nil? || self.android_key_alias.nil? || self.android_key_password.nil?))
        false
    end
    def splash_screen_needed?
        return true if self.platform == 'windows' && self.windows_splash_screen.url.nil?
        false
    end
    def can_build?
        self.app.user.present? && !self.key_needed? && !self.splash_screen_needed?
    end
    def start_url
        if self.path
            if self.app.url.last == '/'
                su = self.app.url + self.path
            else
                su = self.app.url + '/' + self.path
            end
        else
            su = self.app.start_url
        end
        if su.include? '?'
            return su + '&nativegap=' + self.platform
        else
            return su + '?nativegap=' + self.platform
        end
    end
    def icon_url version
        return self.ios_app_store_icon.url if self.platform == 'ios' && version == '_1024x1024' && !self.ios_app_store_icon.nil?
        return self.icon&.send(version)&.url || self.app.icon&.send(version)&.url if self.icon.respond_to?(version) || self.app.icon.respond_to?(version)
        self.windows_splash_screen&.send(version)&.url
    end
    def update_available?
        return true unless self.wrapper_version == ( self.beta ? Settings.nativegap.version.beta.send(self.platform) : Settings.nativegap.version.send(self.platform) )
        false
    end
    def build
        if self.can_build?
            self.update_attributes status: 'processing' unless self.status == 'processing'
            BuildWorker.perform_in Settings.nativegap.delay.build, self.id
        end
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
        self.subscription&.subscribed? && ( self.subscription.plan == 'android_pro' || self.subscription.plan == 'ios_pro' ) ? self.app.error_network_title : 'Oooooops ...'
    end
    def error_network_content
        self.subscription&.subscribed? && ( self.subscription.plan == 'android_pro' || self.subscription.plan == 'ios_pro' ) ? self.app.error_network_content : 'No network connection'
    end
    def error_unsupported_title
        self.subscription&.subscribed? && ( self.subscription.plan == 'android_pro' || self.subscription.plan == 'ios_pro' ) ? self.app.error_unsupported_title : 'Oooooops ...'
    end
    def error_unsupported_content
        self.subscription&.subscribed? && ( self.subscription.plan == 'android_pro' || self.subscription.plan == 'ios_pro' ) ? self.app.error_unsupported_content : 'Your device is unsupported'
    end

    private

    def set_wrapper_version
        self.wrapper_version = ( self.beta ? Settings.nativegap.version.beta.send(self.platform) : Settings.nativegap.version.send(self.platform) )
    end
    def cancel_subscription
        if self.subscription.present?
            subscription = Stripe::Subscription.retrieve self.subscription.stripe_subscription_id
            subscription.delete
        end
    end
    def broadcast
        # if self.status_changed?
        App::BuildBroadcastWorker.perform_async self.id
        # end
    end

end
