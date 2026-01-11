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

ActiveRecord::Schema[8.0].define(version: 2026_01_11_110421) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "zipcode"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email", null: false
    t.bigint "company_id", null: false
    t.string "token", null: false
    t.datetime "invited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_invitations_on_company_id"
    t.index ["email", "company_id"], name: "index_invitations_on_email_and_company_id", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "palette_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "week"
    t.datetime "date"
    t.string "transport"
    t.string "loading_point"
    t.string "delivery_point"
    t.integer "loaded"
    t.integer "rendered"
    t.integer "delivered"
    t.integer "returned"
    t.integer "due"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shipper_id", null: false
    t.bigint "carrier_id", null: false
    t.bigint "recipient_id", null: false
    t.bigint "company_id", null: false
    t.index ["carrier_id"], name: "index_palette_records_on_carrier_id"
    t.index ["company_id"], name: "index_palette_records_on_company_id"
    t.index ["recipient_id"], name: "index_palette_records_on_recipient_id"
    t.index ["shipper_id"], name: "index_palette_records_on_shipper_id"
    t.index ["user_id"], name: "index_palette_records_on_user_id"
  end

  create_table "user_connections", force: :cascade do |t|
    t.bigint "shipper_id", null: false
    t.bigint "carrier_id", null: false
    t.bigint "recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_user_connections_on_carrier_id"
    t.index ["recipient_id"], name: "index_user_connections_on_recipient_id"
    t.index ["shipper_id"], name: "index_user_connections_on_shipper_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.bigint "company_id"
    t.string "first_name"
    t.string "last_name"
    t.boolean "super_admin", default: false, null: false
    t.datetime "deleted_at"
    t.string "invite_token"
    t.datetime "invited_at"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "invitations", "companies"
  add_foreign_key "palette_records", "companies"
  add_foreign_key "palette_records", "users"
  add_foreign_key "palette_records", "users", column: "carrier_id"
  add_foreign_key "palette_records", "users", column: "recipient_id"
  add_foreign_key "palette_records", "users", column: "shipper_id"
  add_foreign_key "user_connections", "users", column: "carrier_id"
  add_foreign_key "user_connections", "users", column: "recipient_id"
  add_foreign_key "user_connections", "users", column: "shipper_id"
  add_foreign_key "users", "companies"
end
