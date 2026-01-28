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

ActiveRecord::Schema[8.1].define(version: 2026_01_26_131235) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bulk_imports", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "enterprise_id", null: false
    t.integer "failed_rows", default: 0
    t.string "original_filename"
    t.string "resource_type", null: false
    t.jsonb "results", default: {}
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.integer "successful_rows", default: 0
    t.integer "total_rows", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["enterprise_id", "resource_type"], name: "index_bulk_imports_on_enterprise_id_and_resource_type"
    t.index ["enterprise_id"], name: "index_bulk_imports_on_enterprise_id"
    t.index ["resource_type"], name: "index_bulk_imports_on_resource_type"
    t.index ["status"], name: "index_bulk_imports_on_status"
    t.index ["user_id"], name: "index_bulk_imports_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.decimal "credit_limit", precision: 10, scale: 2, default: "0.0", null: false
    t.string "email"
    t.bigint "enterprise_id", null: false
    t.string "name", null: false
    t.integer "payment_terms", default: 0, null: false
    t.string "phone_number"
    t.string "tax_id"
    t.string "tax_id_type", default: "ruc", null: false
    t.bigint "ubigeo_id"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id", "tax_id"], name: "idx_customers_on_tax_id_unq_not_null", unique: true, where: "(tax_id IS NOT NULL)"
    t.index ["enterprise_id"], name: "index_customers_on_enterprise_id"
    t.index ["ubigeo_id"], name: "index_customers_on_ubigeo_id"
  end

  create_table "enterprises", force: :cascade do |t|
    t.string "address"
    t.string "comercial_name", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "enterprise_type", null: false
    t.string "logo"
    t.string "phone_number"
    t.string "social_reason"
    t.string "status", null: false
    t.string "subdomain", null: false
    t.bigint "tax_id"
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_enterprises_on_status"
    t.index ["subdomain"], name: "index_enterprises_on_subdomain", unique: true
    t.index ["tax_id"], name: "idx_enterprises_on_tax_id_unq_not_null", unique: true, where: "(tax_id IS NOT NULL)"
  end

  create_table "products", force: :cascade do |t|
    t.decimal "buy_price", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "enterprise_id", null: false
    t.string "name", null: false
    t.bigint "provider_id"
    t.decimal "sell_cash_price", null: false
    t.decimal "sell_credit_price", null: false
    t.string "sku"
    t.string "source_type", null: false
    t.string "status", null: false
    t.integer "stock"
    t.string "unit", null: false
    t.integer "units_per_package"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id", "sku"], name: "idx_products_on_sku_unq_not_null", unique: true, where: "(sku IS NOT NULL)"
    t.index ["enterprise_id"], name: "index_products_on_enterprise_id"
    t.index ["provider_id"], name: "index_products_on_provider_id"
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "enterprise_id", null: false
    t.string "name", null: false
    t.string "phone_number"
    t.string "tax_id"
    t.bigint "ubigeo_id"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id", "tax_id"], name: "idx_providers_on_tax_id_unq_not_null", unique: true, where: "(tax_id IS NOT NULL)"
    t.index ["enterprise_id"], name: "index_providers_on_enterprise_id"
    t.index ["ubigeo_id"], name: "index_providers_on_ubigeo_id"
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
    t.bigint "enterprise_id"
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["enterprise_id"], name: "index_sessions_on_enterprise_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "ubigeos", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.string "level", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ubigeos_on_code", unique: true
    t.index ["level", "parent_id"], name: "index_ubigeos_on_level_and_parent_id"
    t.index ["level"], name: "index_ubigeos_on_level"
    t.index ["parent_id"], name: "index_ubigeos_on_parent_id"
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
    t.string "second_last_name"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["platform_role"], name: "index_users_on_platform_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bulk_imports", "enterprises"
  add_foreign_key "bulk_imports", "users"
  add_foreign_key "customers", "enterprises"
  add_foreign_key "customers", "ubigeos"
  add_foreign_key "products", "enterprises"
  add_foreign_key "products", "providers"
  add_foreign_key "providers", "enterprises"
  add_foreign_key "providers", "ubigeos"
  add_foreign_key "sessions", "enterprises"
  add_foreign_key "sessions", "users"
  add_foreign_key "ubigeos", "ubigeos", column: "parent_id"
  add_foreign_key "user_enterprise_roles", "roles"
  add_foreign_key "user_enterprise_roles", "user_enterprises"
  add_foreign_key "user_enterprises", "enterprises"
  add_foreign_key "user_enterprises", "users"
end
