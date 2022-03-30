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

ActiveRecord::Schema.define(version: 2022_03_30_152905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "pass_id"
    t.bigint "read_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "granted_by_id"
    t.index ["granted_by_id"], name: "index_accesses_on_granted_by_id"
    t.index ["pass_id"], name: "index_accesses_on_pass_id"
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

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "day_use_blocks", force: :cascade do |t|
    t.bigint "day_use_id"
    t.datetime "block_date"
    t.string "weekday"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "created_by_id"
    t.index ["created_by_id"], name: "index_day_use_blocks_on_created_by_id"
    t.index ["day_use_id"], name: "index_day_use_blocks_on_day_use_id"
  end

  create_table "day_use_schedule_pass_types", force: :cascade do |t|
    t.string "name"
    t.integer "price_in_cents"
    t.datetime "deleted_at"
    t.bigint "day_use_schedule_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["day_use_schedule_id"], name: "index_day_use_schedule_pass_types_on_day_use_schedule_id"
  end

  create_table "day_use_schedules", force: :cascade do |t|
    t.string "weekday"
    t.string "name"
    t.text "description"
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.integer "slot_duration_in_minutes"
    t.integer "quantity_per_slot"
    t.bigint "day_use_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["day_use_id"], name: "index_day_use_schedules_on_day_use_id"
  end

  create_table "day_uses", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.text "description"
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "fee_percentage"
    t.boolean "absorb_fee"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.text "terms_of_use"
    t.boolean "deactivated_at"
    t.index ["approved_by_id"], name: "index_day_uses_on_approved_by_id"
    t.index ["partner_id"], name: "index_day_uses_on_partner_id"
  end

  create_table "event_batch_questions", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "event_batch_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_batch_id"], name: "index_event_batch_questions_on_event_batch_id"
    t.index ["question_id"], name: "index_event_batch_questions_on_question_id"
  end

  create_table "event_batches", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name"
    t.string "pass_type"
    t.integer "quantity"
    t.integer "price_in_cents"
    t.integer "order"
    t.datetime "ended_at"
    t.datetime "ends_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_event_batches_on_event_id"
  end

  create_table "event_communications", force: :cascade do |t|
    t.string "subject"
    t.text "content"
    t.bigint "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_event_communications_on_event_id"
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
    t.datetime "released_at"
    t.datetime "sales_started_at"
    t.datetime "sales_finished_at"
    t.bigint "city_id", null: false
    t.bigint "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "created_by_id"
    t.float "fee_percentage"
    t.boolean "absorb_fee"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.text "terms_of_use"
    t.boolean "deactivated_at"
    t.index ["approved_by_id"], name: "index_events_on_approved_by_id"
    t.index ["city_id"], name: "index_events_on_city_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["partner_id"], name: "index_events_on_partner_id"
    t.index ["state_id"], name: "index_events_on_state_id"
  end

  create_table "membership_discounts", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "day_use_id"
    t.bigint "membership_id", null: false
    t.decimal "discount_percentage"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["day_use_id"], name: "index_membership_discounts_on_day_use_id"
    t.index ["event_id"], name: "index_membership_discounts_on_event_id"
    t.index ["membership_id"], name: "index_membership_discounts_on_membership_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "name"
    t.string "short_description"
    t.text "description"
    t.integer "price_in_cents"
    t.bigint "partner_id", null: false
    t.string "iugu_plan_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "fee_percentage"
    t.boolean "absorb_fee"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.text "terms_of_use"
    t.boolean "deactivated_at"
    t.index ["approved_by_id"], name: "index_memberships_on_approved_by_id"
    t.index ["partner_id"], name: "index_memberships_on_partner_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "event_batch_id"
    t.bigint "day_use_schedule_pass_type_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "price_in_cents"
    t.float "fee_percentage", default: 10.0
    t.integer "total_in_cents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "absorb_fee"
    t.index ["day_use_schedule_pass_type_id"], name: "index_order_items_on_day_use_schedule_pass_type_id"
    t.index ["event_batch_id"], name: "index_order_items_on_event_batch_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "invoice_id"
    t.string "invoice_url"
    t.string "invoice_pdf"
    t.string "invoice_status"
    t.string "net_value"
    t.integer "price_in_cents"
    t.string "value"
    t.datetime "invoice_paid_at"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "created_by_id"
    t.bigint "directly_generated_by_id"
    t.index ["created_by_id"], name: "index_orders_on_created_by_id"
    t.index ["directly_generated_by_id"], name: "index_orders_on_directly_generated_by_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "slug"
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
    t.float "fee_percentage", default: 10.0
    t.text "about"
    t.bigint "city_id", null: false
    t.bigint "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "main_contact_id"
    t.index ["city_id"], name: "index_partners_on_city_id"
    t.index ["main_contact_id"], name: "index_partners_on_main_contact_id"
    t.index ["state_id"], name: "index_partners_on_state_id"
  end

  create_table "passes", force: :cascade do |t|
    t.string "qrcode_svg"
    t.string "name"
    t.string "identifier"
    t.bigint "event_id"
    t.bigint "event_batch_id"
    t.bigint "user_membership_id"
    t.bigint "day_use_schedule_pass_type_id"
    t.bigint "partner_id"
    t.bigint "order_item_id"
    t.bigint "user_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "price_in_cents"
    t.float "fee_percentage", default: 10.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "directly_generated_by_id"
    t.boolean "absorb_fee"
    t.index ["day_use_schedule_pass_type_id"], name: "index_passes_on_day_use_schedule_pass_type_id"
    t.index ["directly_generated_by_id"], name: "index_passes_on_directly_generated_by_id"
    t.index ["event_batch_id"], name: "index_passes_on_event_batch_id"
    t.index ["event_id"], name: "index_passes_on_event_id"
    t.index ["order_item_id"], name: "index_passes_on_order_item_id"
    t.index ["partner_id"], name: "index_passes_on_partner_id"
    t.index ["user_id"], name: "index_passes_on_user_id"
    t.index ["user_membership_id"], name: "index_passes_on_user_membership_id"
  end

  create_table "question_answers", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "order_item_id", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_item_id"], name: "index_question_answers_on_order_item_id"
    t.index ["question_id"], name: "index_question_answers_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "day_use_id"
    t.string "prompt"
    t.string "kind"
    t.integer "order"
    t.boolean "optional"
    t.string "options", default: [], array: true
    t.boolean "default", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["day_use_id"], name: "index_questions_on_day_use_id"
    t.index ["event_id"], name: "index_questions_on_event_id"
  end

  create_table "reads", force: :cascade do |t|
    t.bigint "pass_id", null: false
    t.string "read_by"
    t.boolean "result"
    t.string "main_line"
    t.string "secondary_line"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "read_by_id"
    t.index ["pass_id"], name: "index_reads_on_pass_id"
    t.index ["read_by_id"], name: "index_reads_on_read_by_id"
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
    t.string "iugu_subscription_id"
    t.boolean "iugu_active", default: false
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
    t.string "name"
    t.string "document_type"
    t.string "document_number"
    t.string "iugu_customer_id"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.boolean "allow_password_change", default: false
    t.json "tokens"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["partner_id"], name: "index_users_on_partner_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accesses", "passes"
  add_foreign_key "accesses", "reads"
  add_foreign_key "accesses", "users"
  add_foreign_key "accesses", "users", column: "granted_by_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "day_use_blocks", "users", column: "created_by_id"
  add_foreign_key "day_use_schedule_pass_types", "day_use_schedules"
  add_foreign_key "day_use_schedules", "day_uses"
  add_foreign_key "day_uses", "partners"
  add_foreign_key "day_uses", "users", column: "approved_by_id"
  add_foreign_key "event_batch_questions", "event_batches"
  add_foreign_key "event_batch_questions", "questions"
  add_foreign_key "event_batches", "events"
  add_foreign_key "event_communications", "events"
  add_foreign_key "events", "cities"
  add_foreign_key "events", "states"
  add_foreign_key "events", "users", column: "approved_by_id"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "membership_discounts", "day_uses"
  add_foreign_key "membership_discounts", "events"
  add_foreign_key "membership_discounts", "memberships"
  add_foreign_key "memberships", "users", column: "approved_by_id"
  add_foreign_key "order_items", "day_use_schedule_pass_types"
  add_foreign_key "order_items", "event_batches"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "created_by_id"
  add_foreign_key "orders", "users", column: "directly_generated_by_id"
  add_foreign_key "partners", "cities"
  add_foreign_key "partners", "states"
  add_foreign_key "partners", "users", column: "main_contact_id"
  add_foreign_key "passes", "day_use_schedule_pass_types"
  add_foreign_key "passes", "event_batches"
  add_foreign_key "passes", "events"
  add_foreign_key "passes", "order_items"
  add_foreign_key "passes", "partners"
  add_foreign_key "passes", "user_memberships"
  add_foreign_key "passes", "users"
  add_foreign_key "passes", "users", column: "directly_generated_by_id"
  add_foreign_key "question_answers", "order_items"
  add_foreign_key "question_answers", "questions"
  add_foreign_key "questions", "day_uses"
  add_foreign_key "questions", "events"
  add_foreign_key "reads", "passes"
  add_foreign_key "reads", "users", column: "read_by_id"
  add_foreign_key "user_memberships", "memberships"
  add_foreign_key "user_memberships", "users"
end
