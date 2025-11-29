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

ActiveRecord::Schema[8.1].define(version: 2025_11_22_063002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "enterprises", force: :cascade do |t|
    t.string "address", null: false
    t.string "comercial_name", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "logo"
    t.string "phone_number"
    t.string "social_reason", null: false
    t.string "status", null: false
    t.string "subdomain", null: false
    t.bigint "tax_id", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_enterprises_on_status"
    t.index ["subdomain"], name: "index_enterprises_on_subdomain", unique: true
    t.index ["tax_id"], name: "index_enterprises_on_tax_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_roles_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_enterprise_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_enterprise_id", null: false
    t.index ["role_id"], name: "index_user_enterprise_roles_on_role_id"
    t.index ["user_enterprise_id", "role_id"], name: "index_uer_on_ue_id_and_role_id", unique: true
    t.index ["user_enterprise_id"], name: "index_user_enterprise_roles_on_user_enterprise_id"
  end

  create_table "user_enterprises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enterprise_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["enterprise_id"], name: "index_user_enterprises_on_enterprise_id"
    t.index ["user_id", "enterprise_id"], name: "index_user_enterprises_on_user_id_and_enterprise_id", unique: true
    t.index ["user_id"], name: "index_user_enterprises_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_last_name", null: false
    t.string "first_name", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.string "password_digest"
    t.string "phone_number"
    t.string "platform_role", null: false
    t.string "second_last_name", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["platform_role"], name: "index_users_on_platform_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "user_enterprise_roles", "roles"
  add_foreign_key "user_enterprise_roles", "user_enterprises"
  add_foreign_key "user_enterprises", "enterprises"
  add_foreign_key "user_enterprises", "users"
end
