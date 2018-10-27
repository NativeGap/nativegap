# frozen_string_literal: true

class Subscription < ApplicationRecord
  PAYMENT_RESPONSE_TYPES = ['invoice.payment_succeeded',
                            'invoice.payment_failed', 'invoice.upcoming'].freeze

  has_many :invoices
  belongs_to :user
  belongs_to :build, class_name: 'App::Build'

  notification_object

  validates :plan, presence: true

  scope :uncanceled, -> { where.not(canceled_at: nil) }

  def self.names(plan)
    case plan
    when 'android_starter', 'ios_starter'
      I18n.t('d.starter')
    when 'android_pro', 'ios_pro'
      I18n.t('d.professional')
    end
  end

  def subscribed?
    current_period_end.future?
  end

  def canceled?
    !canceled_at.nil?
  end

  def name
    self.class.names plan
  end

  def enable
    stripe.save
    return unless @subscription.stripe.canceled_at.nil?

    update!(canceled_at: nil)
  end

  def cancel
    stripe.delete(at_period_end: true)
    return if stripe.canceled_at.nil?

    update!(canceled_at: Time.strptime(stripe.canceled_at.to_s, '%s'))
  end

  def process_payment(response:)
    handle_succeeded_payment(response)
    send_notification(response)
  end

  def stripe
    @stripe ||= Billing::Subscription::RetrieveStripe.new(
      stripe_subscription_id: stripe_subscription_id
    ).perform
  end

  def create_stripe
    @stripe = Billing::Subscription::CreateStripe.new(
      subscription: self,
      stripe_customer_id: user.stripe.id,
      plan: plan
    ).perform
  end

  private

  def handle_succeeded_payment(response)
    return unless response == 'invoice.payment_succeeded'

    update!(current_period_end: Time.strptime(stripe.current_period_end.to_s,
                                              '%s'))

    Subscription::Invoice.create!(subscription: self,
                                  amount: stripe.plan.amount)
  end

  def send_notification(response)
    return unless PAYMENT_RESPONSE_TYPES.include?(response)

    user.notify(object: self, type: response, push: :ActionMailer)
  end
end
