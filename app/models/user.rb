# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  before_create :stripe
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
    @stripe ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def enable_stripe(token:)
    stripe.source = token
    stripe.save!
  end

  private

  def slug_candidates
    [:publisher, [:publisher, :id]]
  end

  def stripe
    customer = Stripe::Customer.create(
      description: name,
      email: email
    )
    self.stripe_customer_id = customer.id
  end

  def lock
    return false if locked
  end
end
