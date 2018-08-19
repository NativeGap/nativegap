# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_18_093107) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.string "search_keyword"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "app_builds", force: :cascade do |t|
    t.bigint "app_id"
    t.string "platform"
    t.string "path"
    t.string "version", default: "1.0.0", null: false
    t.string "wrapper_version", null: false
    t.boolean "beta", default: false, null: false
    t.string "status", default: "processing", null: false
    t.string "icon"
    t.string "ios_app_store_icon"
    t.string "windows_splash_screen"
    t.string "ios_cert"
    t.string "ios_profile"
    t.string "ios_cert_password"
    t.string "android_keystore"
    t.string "android_key_alias"
    t.string "android_key_password"
    t.string "android_keystore_password"
    t.string "android_statusbar_background", default: "#000000"
    t.string "android_statusbar_style", default: "lightcontent"
    t.string "ios_statusbar_background"
    t.string "ios_statusbar_style", default: "default"
    t.string "windows_tile_background"
    t.string "windows_splash_screen_background"
    t.integer "chrome_width", default: 350
    t.integer "chrome_height", default: 500
    t.string "file"
    t.string "appetize"
    t.string "appetize_public_key"
    t.string "appetize_private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_app_builds_on_app_id"
  end

  create_table "apps", force: :cascade do |t|
    t.bigint "user_id"
    t.string "slug"
    t.string "url"
    t.string "path"
    t.string "name"
    t.string "description"
    t.string "globalization", default: "lang"
    t.boolean "branding", default: true, null: false
    t.string "icon"
    t.string "logo"
    t.string "logo_content_type"
    t.string "background"
    t.string "color"
    t.string "accent"
    t.boolean "statusbar_hide", default: false, null: false
    t.boolean "orientation_portrait", default: true, null: false
    t.boolean "orientation_portrait_flipped", default: true, null: false
    t.boolean "orientation_landscape", default: true, null: false
    t.boolean "orientation_landscape_flipped", default: true, null: false
    t.integer "splash_screen_background"
    t.integer "splash_screen_color"
    t.integer "splash_screen_transition_duration", default: 350
    t.integer "splash_screen_logo_height", default: 50
    t.boolean "splash_screen_loader", default: true, null: false
    t.string "error_network_title", default: "Oooooops ..."
    t.text "error_network_content", default: "No network connection"
    t.string "error_unsupported_title", default: "Oooooops ..."
    t.text "error_unsupported_content", default: "Your device is unsupported"
    t.string "one_signal_app_id"
    t.string "android"
    t.string "ios"
    t.string "windows"
    t.string "chrome"
    t.boolean "appetize", default: false, null: false
    t.string "ability", default: "guest", null: false
    t.string "visibility", default: "private", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_apps_on_user_id"
  end

  create_table "belongings", force: :cascade do |t|
    t.string "belonger_type"
    t.bigint "belonger_id"
    t.string "belongable_type"
    t.bigint "belongable_id"
    t.string "scope"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ability", default: "guest"
    t.index ["belongable_type", "belongable_id"], name: "index_belongings_on_belongable_type_and_belongable_id"
    t.index ["belonger_type", "belonger_id"], name: "index_belongings_on_belonger_type_and_belonger_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "onesignal_id"
    t.string "onesignal_permission"
    t.datetime "last_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onesignal_id"], name: "index_devices_on_onesignal_id"
    t.index ["owner_type", "owner_id"], name: "index_devices_on_owner_type_and_owner_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "native_gap_apps", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "platform"
    t.string "url"
    t.datetime "last_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_native_gap_apps_on_owner_type_and_owner_id"
    t.index ["platform"], name: "index_native_gap_apps_on_platform"
    t.index ["url"], name: "index_native_gap_apps_on_url"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.string "object_type"
    t.bigint "object_id"
    t.boolean "read", default: false, null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["object_type", "object_id"], name: "index_notifications_on_object_type_and_object_id"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
  end

  create_table "subscription_invoices", force: :cascade do |t|
    t.bigint "subscription_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_invoices_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "build_id"
    t.string "plan"
    t.string "stripe_subscription_id"
    t.datetime "current_period_end"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["build_id"], name: "index_subscriptions_on_build_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "slug"
    t.string "first_name"
    t.string "last_name"
    t.string "publisher_name"
    t.string "url"
    t.string "locale", default: "en", null: false
    t.boolean "locked", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "stripe_customer_id"
    t.boolean "has_payment_method", default: false, null: false
    t.boolean "build_notifications", default: false, null: false
    t.boolean "update_notifications", default: false, null: false
    t.string "ability", default: "guest", null: false
    t.string "visibility", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
