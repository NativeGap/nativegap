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
    has_many :invoices, through: :subscriptions, class_name: 'Subscription::Invoice'

    def name
        "#{self.first_name} #{self.last_name}"
    end
    def publisher
        self.publisher_name || self.name
    end
    def admin?
        self.admin
    end

    private

    def slug_candidates
        [:publisher, [:publisher, :id]]
    end
    def stripe
        customer = Stripe::Customer.create(
            description: self.name,
            email: self.email
        )
        self.stripe_customer_id = customer.id
    end
    def lock
        return false if self.locked
    end

end
