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

ActiveRecord::Schema.define(:version => 20120216193404) do

  create_table "course_instances", :force => true do |t|
    t.integer  "course_id",                    :null => false
    t.integer  "position",   :default => 0
    t.string   "name"
    t.string   "path",                         :null => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aplus_url"
  end

  create_table "courseroles", :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "course_id"
    t.string  "role",       :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "code",                                                   :null => false
    t.string   "name"
    t.string   "feedback_read_permission",  :default => "authenticated"
    t.string   "headlines_read_permission", :default => "authenticated"
    t.string   "feedback_write_permission", :default => "authenticated"
    t.boolean  "moderate",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_entries", :force => true do |t|
    t.integer  "course_id",                  :null => false
    t.integer  "position",    :default => 0
    t.string   "caption"
    t.string   "question"
    t.string   "answer"
    t.integer  "thumbs_up",   :default => 0
    t.integer  "thumbs_down", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instanceroles", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.integer "course_instance_id"
    t.string  "role",               :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.string   "nick"
    t.boolean  "anonymous",         :default => true
    t.boolean  "staff",             :default => false
    t.text     "text"
    t.string   "moderation_status", :default => "pending"
    t.integer  "thumbs_up",         :default => 0
    t.integer  "thumbs_down",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "edited_at"
    t.integer  "editor_id"
    t.text     "edit_reason"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "topics", :force => true do |t|
    t.integer  "course_instance_id",                        :null => false
    t.integer  "user_id"
    t.string   "nick"
    t.boolean  "anonymous",          :default => true
    t.string   "caption"
    t.string   "visibility",         :default => "public"
    t.text     "text"
    t.string   "moderation_status",  :default => "pending"
    t.string   "action_status"
    t.integer  "thumbs_up",          :default => 0
    t.integer  "thumbs_down",        :default => 0
    t.datetime "commented_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "studentnumber"
    t.string   "name"
    t.string   "email",                 :limit => 320
    t.string   "locale",                :limit => 5,   :default => "fi"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.boolean  "admin",               :default => false
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  
  create_table "answer_sets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "questionnaire_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "payload"
  end
  add_index "answer_sets", ["questionnaire_id"], :name => "index_answer_sets_on_questionnaire_id"

  create_table "answers", :force => true do |t|
    t.integer "answer_set_id"
    t.integer "questionnaire_question_id"
    t.integer "question_id"
    t.text    "payload"
  end
  add_index "answers", ["answer_set_id"], :name => "index_answers_on_answer_set_id"
  
    create_table "questionnaires", :force => true do |t|
    t.integer  "course_instance_id"
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "payload"
    t.text     "summary"
  end
  add_index "questionnaires", ["course_instance_id"], :name => "index_questionnaires_on_course_instance_id"

  create_table "questions", :force => true do |t|
    t.string   "type"
    t.text     "text"
    t.string   "hint"
    t.text     "params"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "questionnaire_id"
    t.text     "payload"
  end
  
  create_table "orientations", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.integer  "course_instance_id"
    t.string   "studentnumber"
    t.text     "payload",           :null => false
    t.datetime "created_at"
  end
end
