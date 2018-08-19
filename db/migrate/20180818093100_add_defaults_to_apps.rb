# frozen_string_literal: true

class AddDefaultsToApps < ActiveRecord::Migration[5.2]
  def change
    change_column_default :apps, :globalization, from: nil, to: 'lang'
    change_column_default :apps, :splash_screen_transition_duration, from: nil, to: 350
    change_column_default :apps, :splash_screen_logo_height, from: nil, to: 50
    change_column_default :apps, :error_network_title, from: nil, to: 'Oooooops ...'
    change_column_default :apps, :error_network_content, from: nil, to: 'No network connection'
    change_column_default :apps, :error_unsupported_title, from: nil, to: 'Oooooops ...'
    change_column_default :apps, :error_unsupported_content, from: nil, to: 'Your device is unsupported'

    change_column_null :apps, :globalization, from: true, to: false
    change_column_null :apps, :splash_screen_transition_duration, from: true, to: false
    change_column_null :apps, :splash_screen_logo_height, from: true, to: false
    change_column_null :apps, :error_network_title, from: true, to: false
    change_column_null :apps, :error_network_content, from: true, to: false
    change_column_null :apps, :error_unsupported_title, from: true, to: false
    change_column_null :apps, :error_unsupported_content, from: true, to: false
  end
end
