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

ActiveRecord::Schema.define(version: 20230923120507) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "overtime_end_at"
    t.string "overtime_task"
    t.integer "overtime_status", default: 0
    t.integer "overtime_approver_id"
    t.integer "attendance_status", default: 0
    t.boolean "next_day"
    t.boolean "approval_status"
    t.integer "monthly_approval_status", default: 0
    t.integer "monthly_approval_approver_id"
    t.integer "attendance_approver_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number", null: false
    t.string "base_name", null: false
    t.string "base_type", default: "0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_name"], name: "index_bases_on_base_name", unique: true
    t.index ["base_number"], name: "index_bases_on_base_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2023-09-10 08:00:00"
    t.datetime "work_time", default: "2023-09-10 07:30:00"
    t.boolean "superior", default: false
    t.string "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time", default: "2023-09-10 09:00:00"
    t.datetime "designated_work_end_time", default: "2023-09-10 18:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
