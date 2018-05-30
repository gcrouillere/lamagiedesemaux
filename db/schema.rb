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

ActiveRecord::Schema.define(version: 2018_05_29_071624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "content", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "attachinary_files", id: :serial, force: :cascade do |t|
    t.string "attachinariable_type"
    t.integer "attachinariable_id"
    t.string "scope"
    t.string "public_id"
    t.string "version"
    t.integer "width"
    t.integer "height"
    t.string "format"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent"
  end

  create_table "basketlines", id: :serial, force: :cascade do |t|
    t.integer "ceramique_id"
    t.integer "quantity"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ceramique_id"], name: "index_basketlines_on_ceramique_id"
    t.index ["order_id"], name: "index_basketlines_on_order_id"
  end

  create_table "bookings", id: :serial, force: :cascade do |t|
    t.datetime "day", null: false
    t.integer "capacity", null: false
    t.boolean "full", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course"
    t.integer "duration"
  end

  create_table "calendarupdates", id: :serial, force: :cascade do |t|
    t.datetime "period_start", null: false
    t.datetime "period_end", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lesson_id"
    t.index ["lesson_id"], name: "index_calendarupdates_on_lesson_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_connections", id: false, force: :cascade do |t|
    t.integer "category_a_id", null: false
    t.integer "category_b_id", null: false
  end

  create_table "ceramiques", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "stock", null: false
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "slug"
    t.integer "weight"
    t.integer "offer_id"
    t.integer "position"
    t.index ["category_id"], name: "index_ceramiques_on_category_id"
    t.index ["offer_id"], name: "index_ceramiques_on_offer_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
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

  create_table "lessons", id: :serial, force: :cascade do |t|
    t.datetime "start", null: false
    t.integer "duration", null: false
    t.integer "user_id", null: false
    t.boolean "confirmed", default: false, null: false
    t.integer "student", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_lessons_on_user_id"
  end

  create_table "offers", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.boolean "showcased", default: false, null: false
    t.float "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.string "state"
    t.string "ceramique"
    t.integer "amount_cents", default: 0, null: false
    t.json "payment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "lesson_id"
    t.integer "port_cents", default: 0, null: false
    t.boolean "take_away"
    t.integer "weight"
    t.index ["lesson_id"], name: "index_orders_on_lesson_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "shipping_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "alpha2", null: false
    t.integer "weight", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "adress"
    t.string "zip_code"
    t.string "city"
    t.string "provider"
    t.string "uid"
    t.string "facebook_picture_url"
    t.string "token"
    t.datetime "token_expiry"
    t.string "tracking"
    t.string "country", default: "FR", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "articles", "users"
  add_foreign_key "basketlines", "ceramiques"
  add_foreign_key "basketlines", "orders"
  add_foreign_key "calendarupdates", "lessons"
  add_foreign_key "ceramiques", "categories"
  add_foreign_key "ceramiques", "offers"
  add_foreign_key "lessons", "users"
  add_foreign_key "orders", "lessons"
  add_foreign_key "orders", "users"
end
