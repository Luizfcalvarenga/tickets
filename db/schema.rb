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

ActiveRecord::Schema.define(version: 2021_10_15_013359) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "membership_id"
    t.bigint "read_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "granted_by_id"
    t.index ["event_id"], name: "index_accesses_on_event_id"
    t.index ["granted_by_id"], name: "index_accesses_on_granted_by_id"
    t.index ["membership_id"], name: "index_accesses_on_membership_id"
    t.index ["read_id"], name: "index_accesses_on_read_id"
    t.index ["user_id"], name: "index_accesses_on_user_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "batches", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name"
    t.integer "quantity"
    t.decimal "price"
    t.integer "order"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_batches_on_event_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "scheduled_start"
    t.datetime "scheduled_end"
    t.bigint "partner_id", null: false
    t.string "cep"
    t.string "street_name"
    t.string "street_number"
    t.string "neighborhood"
    t.string "address_complement"
    t.datetime "sales_started_at"
    t.datetime "sales_finished_at"
    t.bigint "city_id", null: false
    t.bigint "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "created_by_id"
    t.index ["city_id"], name: "index_events_on_city_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["partner_id"], name: "index_events_on_partner_id"
    t.index ["state_id"], name: "index_events_on_state_id"
  end

  create_table "membership_events", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "membership_id", null: false
    t.boolean "free"
    t.decimal "discount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_membership_events_on_event_id"
    t.index ["membership_id"], name: "index_membership_events_on_membership_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "name"
    t.string "short_description"
    t.string "description"
    t.decimal "price"
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_memberships_on_partner_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "cnpj"
    t.string "kind"
    t.string "contact_phone_1"
    t.string "contact_phone_2"
    t.string "contact_email"
    t.string "cep"
    t.string "street_name"
    t.string "street_number"
    t.string "neighborhood"
    t.string "address_complement"
    t.bigint "city_id", null: false
    t.bigint "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "main_contact_id"
    t.index ["city_id"], name: "index_partners_on_city_id"
    t.index ["main_contact_id"], name: "index_partners_on_main_contact_id"
    t.index ["state_id"], name: "index_partners_on_state_id"
  end

  create_table "qrcodes", force: :cascade do |t|
    t.string "svg_source"
    t.string "identifier"
    t.bigint "event_id"
    t.bigint "membership_id"
    t.bigint "user_id", null: false
    t.decimal "amount_paid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "batch_id"
    t.index ["batch_id"], name: "index_qrcodes_on_batch_id"
    t.index ["event_id"], name: "index_qrcodes_on_event_id"
    t.index ["membership_id"], name: "index_qrcodes_on_membership_id"
    t.index ["user_id"], name: "index_qrcodes_on_user_id"
  end

  create_table "reads", force: :cascade do |t|
    t.bigint "qrcode_id", null: false
    t.bigint "session_id", null: false
    t.boolean "result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["qrcode_id"], name: "index_reads_on_qrcode_id"
    t.index ["session_id"], name: "index_reads_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id"
    t.datetime "ended_at"
    t.string "identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_sessions_on_event_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "acronym"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "membership_id", null: false
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["membership_id"], name: "index_user_memberships_on_membership_id"
    t.index ["user_id"], name: "index_user_memberships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "access", default: "user"
    t.bigint "partner_id"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.boolean "allow_password_change", default: false
    t.json "tokens"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["partner_id"], name: "index_users_on_partner_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accesses", "events"
  add_foreign_key "accesses", "memberships"
  add_foreign_key "accesses", "reads"
  add_foreign_key "accesses", "users"
  add_foreign_key "accesses", "users", column: "granted_by_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "batches", "events"
  add_foreign_key "events", "cities"
  add_foreign_key "events", "states"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "membership_events", "events"
  add_foreign_key "membership_events", "memberships"
  add_foreign_key "partners", "cities"
  add_foreign_key "partners", "states"
  add_foreign_key "partners", "users", column: "main_contact_id"
  add_foreign_key "qrcodes", "events"
  add_foreign_key "qrcodes", "memberships"
  add_foreign_key "qrcodes", "users"
  add_foreign_key "reads", "qrcodes"
  add_foreign_key "reads", "sessions"
  add_foreign_key "sessions", "events"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_memberships", "memberships"
  add_foreign_key "user_memberships", "users"
end
