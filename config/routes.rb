# frozen_string_literal: true

Rails.application.routes.draw do
  scope protocol: (Rails.env.production? ? 'https' : 'http') do
    mount Pwa::Engine, at: ''
    mount ActionCable.server, at: '/cable'

    require 'sidekiq/web'
    authenticated :user, lambda { |u| u.admin? } do
      Sidekiq::Web.set(
        :session_secret,
        Rails.application.credentials.secret_key_base
      )
      mount Sidekiq::Web, at: '/sidekiq'
    end

    constraints subdomain: '' do
      devise_for :users,
                 path: '',
                 skip: [:sessions, :registrations, :passwords, :confirmations]
      as :user do
        get 'login', to: 'users/sessions#new', as: :new_user_session
        post 'login', to: 'users/sessions#create', as: :user_session
        delete 'logout', to: 'users/sessions#destroy', as: :destroy_user_session
        get 'settings',
            to: 'users/registrations#edit',
            as: :edit_user_registration
        get 'signup', to: 'users/registrations#new', as: :new_user_registration
        post 'signup', to: 'users/registrations#create', as: :user_registration
        put 'account', to: 'users/registrations#update'
        get 'forgot', to: 'users/passwords#new', as: :new_user_password
        get 'password', to: 'users/passwords#edit', as: :edit_user_password
        put 'password', to: 'users/passwords#update'
        post 'password', to: 'users/passwords#create'
        get 'confirm', to: 'users/confirmations#new', as: :new_user_confirmation
        post 'confirm', to: 'users/confirmations#create'
        get 'activate', to: 'users/confirmations#show', as: :user_confirmation
      end
      get 'users/:id', to: 'users#show', as: :user

      resources :subscriptions,
                path: 'billing',
                only: [:index, :create, :update, :destroy]
      get 'checkout', to: 'subscriptions#new', constraints: Modalist::Ajax.new
      post 'stripe/webhook', to: 'subscriptions#stripe_webhook'
      namespace :users, path: '' do
        get 'payment-method',
            to: 'payment_methods#show',
            constraints: Modalist::Ajax.new
        get 'payment-method/add',
            to: 'payment_methods#edit',
            as: :edit_payment_method,
            constraints: Modalist::Ajax.new
        post 'payment-method', to: 'payment_methods#update'
      end

      resources :apps, path: 'dashboard', except: [:new] do
        namespace :apps, path: '' do
          resources :builds, only: [:update]
          get 'builds/:id/version',
              to: 'builds#version',
              as: :version,
              constraints: Modalist::Ajax.new
          get 'builds/:id/key',
              to: 'builds#key',
              as: :key,
              constraints: Modalist::Ajax.new
          get 'builds/:id/splash-screen',
              to: 'builds#splash_screen',
              as: :splash_screen,
              constraints: Modalist::Ajax.new
        end
      end
      get 'build', to: 'apps#new', as: :new_app

      get 'explore', to: 'explore#index'
      get 'explore/:id', to: 'explore#show', as: :app_explore
      get 'explore/:id/install',
          to: 'explore#install',
          as: :install_app_explore,
          constraints: Modalist::Ajax.new

      get 'language', to: 'welcome#language', constraints: Modalist::Ajax.new
      get 'notify', to: 'welcome#notify', constraints: Modalist::Ajax.new
      root 'welcome#index'
    end
  end

  match '*path', to: 'r404#not_found', via: :all
end
