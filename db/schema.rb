# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_201_003_110_720) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pgcrypto'
  enable_extension 'plpgsql'

  create_table 'events', id: :binary, force: :cascade do |t|
    t.string 'name'
    t.datetime 'date'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'good_jobs', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.text 'queue_name'
    t.integer 'priority'
    t.jsonb 'serialized_params'
    t.datetime 'scheduled_at'
    t.datetime 'performed_at'
    t.datetime 'finished_at'
    t.text 'error'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[queue_name scheduled_at], name: 'index_good_jobs_on_queue_name_and_scheduled_at', where: '(finished_at IS NULL)'
    t.index ['scheduled_at'], name: 'index_good_jobs_on_scheduled_at', where: '(finished_at IS NULL)'
  end

  create_table 'perform_every', force: :cascade do |t|
    t.string 'job_name'
    t.string 'typ'
    t.string 'value'
    t.string 'history', array: true
    t.datetime 'last_performed_at'
    t.datetime 'perform_at'
    t.boolean 'deprecated', default: false, null: false
    t.index ['deprecated'], name: 'index_perform_every_on_deprecated'
    t.index %w[job_name typ value], name: 'perform_every_unique_job', unique: true
  end

  create_table 'reservations', id: :binary, force: :cascade do |t|
    t.binary 'user_id', null: false
    t.binary 'ticket_id', null: false
    t.integer 'amount', null: false
    t.decimal 'total_price', null: false
    t.boolean 'paid', default: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['ticket_id'], name: 'index_reservations_on_ticket_id'
    t.index ['user_id'], name: 'index_reservations_on_user_id'
  end

  create_table 'tickets', id: :binary, force: :cascade do |t|
    t.string 'name', null: false
    t.string 'option', null: false
    t.integer 'initial_amount', null: false
    t.decimal 'price', null: false
    t.binary 'event_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[event_id name], name: 'index_tickets_on_event_id_and_name', unique: true
    t.index ['event_id'], name: 'index_tickets_on_event_id'
  end

  create_table 'users', id: :binary, force: :cascade do |t|
    t.string 'email', null: false
    t.string 'password_digest', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
  end

  add_foreign_key 'reservations', 'tickets'
  add_foreign_key 'reservations', 'users'
  add_foreign_key 'tickets', 'events'
end
