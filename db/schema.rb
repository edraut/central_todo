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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110311170407) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_emails", :force => true do |t|
    t.integer  "project_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_sharers", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.datetime "due_date"
    t.text     "description"
    t.string   "type"
    t.integer  "user_id"
    t.integer  "position"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "situations", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_situations", :force => true do |t|
    t.integer  "task_id"
    t.integer  "situation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "title"
    t.integer  "project_id"
    t.datetime "due_date"
    t.text     "description"
    t.string   "type"
    t.integer  "user_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "priority",    :default => false, :null => false
    t.string   "state"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                        :null => false
    t.string   "name"
    t.string   "type"
    t.string   "state",               :default => "not_valid", :null => false
    t.string   "time_zone"
    t.string   "crypted_password",                             :null => false
    t.string   "password_salt",                                :null => false
    t.string   "persistence_token",                            :null => false
    t.string   "single_access_token",                          :null => false
    t.string   "perishable_token",                             :null => false
    t.integer  "login_count",         :default => 0,           :null => false
    t.integer  "failed_login_count",  :default => 0,           :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "cim_id"
    t.boolean  "card_valid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_help_text",      :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
