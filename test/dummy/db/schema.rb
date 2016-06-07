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

ActiveRecord::Schema.define(version: 20160607100350) do

  create_table "descriptors", force: :cascade do |t|
    t.string   "type"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.string   "symbol"
    t.string   "name"
    t.text     "description"
    t.integer  "index"
    t.integer  "value"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "descriptors", ["parent_type", "parent_id"], name: "index_descriptors_on_parent_type_and_parent_id"
  add_index "descriptors", ["type", "index"], name: "index_descriptors_on_type_and_index"
  add_index "descriptors", ["type", "symbol"], name: "index_descriptors_on_type_and_symbol"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
