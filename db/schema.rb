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

ActiveRecord::Schema.define(version: 20180206170723) do

  create_table "scrap_entities", force: :cascade do |t|
    t.string   "url"
    t.text     "params"
    t.integer  "category"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "similar_web_infos", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "url"
    t.integer  "status"
    t.string   "globalrank"
    t.string   "traffic"
    t.string   "category"
    t.string   "topcategories"
    t.string   "description"
    t.string   "toptags"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["site_id"], name: "index_similar_web_infos_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
