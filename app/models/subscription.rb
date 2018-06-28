# frozen_string_literal: true

class Subscription < ApplicationRecord
  has_many :invoices
  belongs_to :user
  belongs_to :build, class_name: 'App::Build'

  notification_object

  validates :plan, presence: true

  scope :uncanceled, -> { where.not(canceled_at: nil) }

  def subscribed?
    current_period_end.future?
  end

  def canceled?
    !canceled_at.nil?
  end

  def name
    self.class.names plan
  end

  def self.names(plan)
    case plan
    when 'android_starter', 'ios_starter'
      I18n.t('d.starter')
    when 'android_pro', 'ios_pro'
      I18n.t('d.professional')
    end
  end
end
