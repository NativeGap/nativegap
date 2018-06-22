class CreateApps < ActiveRecord::Migration[5.1]
    def change
        create_table :apps do |t|

            t.references :user, index: true

            # General
            t.string :slug, unique: true
            t.string :url
            t.string :path
            t.string :name
            t.string :description
            t.string :globalization
            t.boolean :branding, null: false, default: true

            # Imagery
            t.string :icon
            t.string :logo
            t.string :logo_content_type

            # Design
            t.string :background
            t.string :color
            t.string :accent
            t.boolean :statusbar_hide, null: false, default: false
            t.boolean :orientation_portrait, null: false, default: true
            t.boolean :orientation_portrait_flipped, null: false, default: true
            t.boolean :orientation_landscape, null: false, default: true
            t.boolean :orientation_landscape_flipped, null: false, default: true
            t.integer :splash_screen_background
            t.integer :splash_screen_color
            t.integer :splash_screen_transition_duration
            t.integer :splash_screen_logo_height
            t.boolean :splash_screen_loader, null: false, default: true

            # Features
            ## Errors
            t.string :error_network_title
            t.text :error_network_content
            t.string :error_unsupported_title
            t.text :error_unsupported_content
            ## Notifications
            t.string :one_signal_app_id

            # Explore
            t.string :android
            t.string :ios
            t.string :windows
            t.string :chrome
            t.boolean :appetize, null: false, default: false

            # CanCanCan
            t.string :ability, null: false, default: 'guest'
            t.string :visibility, null: false, default: 'private'


            t.timestamps

        end
    end
end
