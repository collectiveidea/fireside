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

ActiveRecord::Schema.define(version: 20140124165455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "messages", force: true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.integer  "room_id"
    t.boolean  "starred",    default: false, null: false
  end

  add_index "messages", ["created_at"], name: "index_messages_on_created_at", using: :btree
  add_index "messages", ["room_id"], name: "index_messages_on_room_id", using: :btree
  add_index "messages", ["starred"], name: "index_messages_on_starred", using: :btree

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.string   "topic"
    t.boolean  "open_to_guests",               default: false, null: false
    t.string   "active_token_value", limit: 5
    t.boolean  "locked",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rooms", ["active_token_value"], name: "index_rooms_on_active_token_value", unique: true, using: :btree
  add_index "rooms", ["created_at"], name: "index_rooms_on_created_at", using: :btree
  add_index "rooms", ["name"], name: "index_rooms_on_name", unique: true, using: :btree

end
