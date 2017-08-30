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

ActiveRecord::Schema.define(version: 20170802220139) do

  create_table "influx_invoice_payments", force: :cascade do |t|
    t.string "email", limit: 191
    t.integer "subscriber_id"
    t.integer "subscription_id"
    t.integer "plan_id"
    t.string "uuid", limit: 191
    t.integer "amount"
    t.integer "fee_amount"
    t.string "currency"
    t.string "state"
    t.string "stripe_id"
    t.string "card_last4"
    t.date "card_expiration"
    t.string "card_type"
    t.text "error"
    t.datetime "payment_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_influx_invoice_payments_on_email"
    t.index ["subscription_id"], name: "index_influx_invoice_payments_on_subscription_id"
    t.index ["uuid"], name: "index_influx_invoice_payments_on_uuid"
  end

  create_table "influx_plans", force: :cascade do |t|
    t.string "stripe_id"
    t.string "name", limit: 250
    t.integer "amount"
    t.string "interval", limit: 250
    t.integer "interval_count"
    t.integer "trial_period_days"
    t.boolean "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["stripe_id"], name: "index_influx_plans_on_stripe_id"
  end

  create_table "influx_stripe_events", force: :cascade do |t|
    t.string "stripe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["stripe_id"], name: "index_influx_stripe_events_on_stripe_id"
  end

  create_table "influx_subscriptions", force: :cascade do |t|
    t.string "state", null: false
    t.integer "influx_plan_id", null: false
    t.integer "subscriber_id", null: false
    t.string "stripe_customer_id"
    t.string "email"
    t.datetime "started_at"
    t.boolean "cancel_at_period_end"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "ended_at"
    t.datetime "trial_start"
    t.datetime "trial_end"
    t.datetime "canceled_at"
    t.string "stripe_status"
    t.string "stripe_id"
    t.string "stripe_token"
    t.string "card_last4"
    t.date "card_expiration"
    t.string "card_type"
    t.text "error"
    t.integer "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["influx_plan_id"], name: "index_influx_subscriptions_on_influx_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id", limit: 191
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
  end

end
