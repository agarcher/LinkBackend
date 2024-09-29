# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_29_150748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "user_matches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "opt_in_sms_sent"
    t.string "opt_in_response"
    t.boolean "opt_in_result"
    t.datetime "topic_sms_sent"
    t.string "topic_response"
    t.boolean "matching_started", default: false
    t.boolean "matching_completed", default: false
    t.bigint "matched_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "match_message"
    t.index ["matched_user_id"], name: "index_user_matches_on_matched_user_id"
    t.index ["user_id"], name: "index_user_matches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "availability"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "user_matches", "users"
  add_foreign_key "user_matches", "users", column: "matched_user_id"
end
