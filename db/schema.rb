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

ActiveRecord::Schema[8.0].define(version: 2025_06_12_232610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "maintenance_reports", force: :cascade do |t|
    t.text "description"
    t.integer "priority"
    t.integer "status"
    t.datetime "reported_at"
    t.bigint "vehicle_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_at"], name: "index_maintenance_reports_on_reported_at"
    t.index ["status", "priority"], name: "index_maintenance_reports_on_status_and_priority"
    t.index ["status", "reported_at"], name: "index_maintenance_reports_on_status_and_reported_at"
    t.index ["user_id"], name: "index_maintenance_reports_on_user_id"
    t.index ["vehicle_id", "status"], name: "index_maintenance_reports_on_vehicle_id_and_status"
    t.index ["vehicle_id"], name: "index_maintenance_reports_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "license_plate"
    t.string "make"
    t.string "model"
    t.integer "year"
    t.integer "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
    t.index ["status"], name: "index_vehicles_on_status"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  add_foreign_key "maintenance_reports", "users"
  add_foreign_key "maintenance_reports", "vehicles"
  add_foreign_key "vehicles", "users"
end
