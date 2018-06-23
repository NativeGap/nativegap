# frozen_string_literal: true

class CreateAppBuilds < ActiveRecord::Migration[5.1]
  def change
    create_table :app_builds do |t|
      t.references :app, index: true

      # General
      t.string :platform
      t.string :path
      t.string :version, null: false, default: '1.0.0'
      t.string :wrapper_version, null: false
      t.boolean :beta, null: false, default: false
      t.string :status, default: 'processing', null: false

      # Imagery
      t.string :icon
      t.string :ios_app_store_icon
      t.string :windows_splash_screen

      # Keys
      t.string :ios_cert
      t.string :ios_profile
      t.string :ios_cert_password
      t.string :android_keystore
      t.string :android_key_alias
      t.string :android_key_password
      t.string :android_keystore_password

      # Android
      t.string :android_statusbar_background
      t.string :android_statusbar_style
      # iOS
      t.string :ios_statusbar_background
      t.string :ios_statusbar_style
      # Windows
      t.string :windows_tile_background
      t.string :windows_splash_screen_background
      # Chrome
      t.integer :chrome_width
      t.integer :chrome_height

      # CarrierWave
      t.string :file

      # Appetize
      t.string :appetize
      t.string :appetize_public_key
      t.string :appetize_private_key

      t.timestamps
    end
  end
end
