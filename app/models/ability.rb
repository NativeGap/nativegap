# frozen_string_literal: true

class Ability
  include CanCan::Ability
  include CanCanCan::System::Ability

  def initialize(user)
    user ||= User.new
    modify [:create, :read, :update, :destroy]

    abilities User, user, column: ''
    abilities App, user
    can :create, App
    can :manage, App::Build do |build|
      build.app.user_id == user.id
    end
    abilities Notification, user, column: 'target',
                                  polymorphic: true,
                                  public_abilities: false
    abilities Subscription, user, public_abilities: false
    can :create, Subscription
  end
end
