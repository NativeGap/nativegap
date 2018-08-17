# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  before_create :create_stripe
  before_save :lock

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  onsignal
  nativegap
  notification_target

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :apps, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :invoices, through: :subscriptions,
                      class_name: 'Subscription::Invoice'

  def name
    "#{first_name} #{last_name}"
  end

  def publisher
    publisher_name || name
  end

  def admin?
    admin
  end

  def stripe
    @stripe ||= Billing::Customer::ReceiveStripe.new(
      stripe_customer_id: stripe_customer_id
    ).perform
  end

  def enable_stripe(token:)
    Billing::Customer::EnableStripe.new(
      stripe_customer: stripe,
      token: token
    ).perform
  end

  private

  def slug_candidates
    [:publisher, [:publisher, :id]]
  end

  def create_stripe
    @stripe = Billing::Customer::CreateStripe.new(name: name, email: email)
                                             .perform
    self.stripe_customer_id = @stripe.id
  end

  def lock
    return false if locked
  end
end
