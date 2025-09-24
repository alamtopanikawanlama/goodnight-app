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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_024932) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "follower_id", null: false
    t.uuid "following_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id", "following_id"], name: "index_follows_on_follower_id_and_following_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id_for_count"
    t.index ["following_id"], name: "index_follows_on_following_id"
    t.index ["following_id"], name: "index_follows_on_following_id_for_count"
  end

  create_table "sleep_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "clock_in_at", null: false
    t.datetime "clock_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clock_in_at", "clock_out_at"], name: "index_sleep_records_for_duration_calc", where: "(clock_out_at IS NOT NULL)"
    t.index ["clock_in_at"], name: "index_sleep_records_on_clock_in_at"
    t.index ["clock_out_at"], name: "index_sleep_records_on_clock_out_at"
    t.index ["created_at", "user_id"], name: "index_sleep_records_on_created_at_and_user_id"
    t.index ["user_id", "clock_in_at"], name: "index_sleep_records_ongoing_by_user", where: "(clock_out_at IS NULL)"
    t.index ["user_id", "clock_out_at"], name: "index_sleep_records_on_user_id_and_clock_out_at"
    t.index ["user_id", "created_at"], name: "index_sleep_records_completed_by_user_date", where: "(clock_out_at IS NOT NULL)"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at", "id"], name: "index_users_on_created_at_and_id"
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "follows", "users", column: "following_id"
  add_foreign_key "sleep_records", "users"
end
