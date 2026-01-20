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

ActiveRecord::Schema[8.0].define(version: 2026_01_18_134903) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "zipcode"
    t.string "country"
    t.bigint "role_id"
    t.boolean "approved", default: false
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_companies_on_role_id"
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

  create_table "palette_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shipper_id", null: false
    t.bigint "carrier_id", null: false
    t.bigint "recipient_id", null: false
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
    t.bigint "company_id", null: false
    t.bigint "user_connection_id", null: false
    t.index ["carrier_id"], name: "index_palette_records_on_carrier_id"
    t.index ["company_id"], name: "index_palette_records_on_company_id"
    t.index ["recipient_id"], name: "index_palette_records_on_recipient_id"
    t.index ["shipper_id"], name: "index_palette_records_on_shipper_id"
    t.index ["user_connection_id"], name: "index_palette_records_on_user_connection_id"
    t.index ["user_id"], name: "index_palette_records_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signup_requests", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "admin_email", null: false
    t.text "message"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id", null: false
    t.index ["admin_email"], name: "index_signup_requests_on_admin_email", unique: true
    t.index ["role_id"], name: "index_signup_requests_on_role_id"
  end

  create_table "user_connections", force: :cascade do |t|
    t.bigint "requester_id", null: false
    t.bigint "receiver_id", null: false
    t.bigint "role_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.index ["invitation_token"], name: "index_user_connections_on_invitation_token", unique: true
    t.index ["receiver_id"], name: "index_user_connections_on_receiver_id"
    t.index ["requester_id", "receiver_id"], name: "index_user_connections_on_requester_id_and_receiver_id", unique: true
    t.index ["requester_id"], name: "index_user_connections_on_requester_id"
    t.index ["role_id"], name: "index_user_connections_on_role_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "function", default: 0
    t.boolean "admin", default: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "super_admin", default: false, null: false
    t.datetime "deleted_at"
    t.string "invite_token"
    t.datetime "invited_at"
    t.string "phone"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
  end

  add_foreign_key "companies", "roles"
  add_foreign_key "invitations", "companies"
  add_foreign_key "palette_records", "companies"
  add_foreign_key "palette_records", "user_connections"
  add_foreign_key "signup_requests", "roles"
  add_foreign_key "user_connections", "companies", column: "receiver_id"
  add_foreign_key "user_connections", "companies", column: "requester_id"
  add_foreign_key "user_connections", "roles"
  add_foreign_key "users", "companies"
end
