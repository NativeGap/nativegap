# frozen_string_literal: true

class AddDefaultsToAppBuilds < ActiveRecord::Migration[5.2]
  def change
    change_column_default :app_builds, :android_statusbar_background, from: nil, to: '#000000'
    change_column_default :app_builds, :android_statusbar_style, from: nil, to: 'lightcontent'
    change_column_default :app_builds, :ios_statusbar_style, from: nil, to: 'default'
    change_column_default :app_builds, :chrome_width, from: nil, to: 350
    change_column_default :app_builds, :chrome_height, from: nil, to: 500

    change_column_null :app_builds, :android_statusbar_background, from: true, to: false
    change_column_null :app_builds, :android_statusbar_style, from: true, to: false
    change_column_null :app_builds, :ios_statusbar_style, from: true, to: false
    change_column_null :app_builds, :chrome_width, from: true, to: false
    change_column_null :app_builds, :chrome_height, from: true, to: false
  end
end
