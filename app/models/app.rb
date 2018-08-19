# frozen_string_literal: true

class App < ApplicationRecord
  before_save :set_logo_content_type
  after_create_commit :build

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  notification_object
  mount_uploader :icon, IconUploader
  mount_uploader :logo, LogoUploader
  process_in_background :icon if Rails.env.production?

  validates :url, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :icon, presence: true, integrity: true, processing: true
  validates :logo, presence: true, integrity: true, processing: true
  validates :background, presence: true, length: { minimum: 7, maximum: 7 }
  validates :color, presence: true, length: { minimum: 7, maximum: 7 }
  validates :accent, presence: true, length: { minimum: 7, maximum: 7 }

  has_many :builds, class_name: 'App::Build', dependent: :destroy
  belongs_to :user, optional: true

  def name_without_spaces
    name.sub(' ', '')
  end

  def safe_description
    description.gsub(/&/, 'and')
  end

  def package_id
    url.sub('https://', '').split('/').first.split('.').reverse.join('.')
  end

  def start_url
    if path
      url.last == '/' ? "#{url}#{path}" : "#{url}/#{path}"
    else
      url
    end
  end

  def build
    builds.create!(platform: 'android')
    builds.create!(platform: 'ios')
    builds.create!(platform: 'windows', version: '1.1.0')
    builds.create!(platform: 'chrome')
  end

  private

  def slug_candidates
    [:name, [:name, :id]]
  end

  def set_logo_content_type
    return unless logo.present? && logo_changed?
    self.logo_content_type = logo.url.split('.').last
  end
end
