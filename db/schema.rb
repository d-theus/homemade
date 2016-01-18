# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160118112619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree

  create_table "customers", force: true do |t|
    t.string   "name",       null: false
    t.string   "phone",      null: false
    t.string   "address",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  add_index "customers", ["phone"], name: "index_customers_on_phone", unique: true, using: :btree

  create_table "inventory_items", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_items_recipes", id: false, force: true do |t|
    t.integer "recipe_id",         null: false
    t.integer "inventory_item_id", null: false
  end

  create_table "orders", force: true do |t|
    t.integer  "count",                          null: false
    t.string   "payment_method",                 null: false
    t.integer  "customer_id",                    null: false
    t.string   "status",         default: "new"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "by_phone"
  end

  create_table "recipes", force: true do |t|
    t.string   "title"
    t.string   "subtitle"
    t.integer  "cooking_time"
    t.integer  "calories"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "day",          limit: 2
    t.string   "photo"
  end

  add_index "recipes", ["day"], name: "index_recipes_on_day", unique: true, using: :btree

  create_table "week_recipes", force: true do |t|
    t.integer "recipe_id"
    t.integer "day"
  end

  add_index "week_recipes", ["recipe_id"], name: "index_week_recipes_on_recipe_id", using: :btree

  create_table "weekly_menu_subscriptions", force: true do |t|
    t.string   "email",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
