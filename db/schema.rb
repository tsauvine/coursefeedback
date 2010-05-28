# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100419123309) do

  create_table "course_instances", :force => true do |t|
    t.integer  "course_id"
    t.integer  "position",   :default => 0
    t.string   "name"
    t.string   "path",                         :null => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courseroles", :force => true do |t|
    t.string  "user_login", :null => false
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
    t.string  "user_login",         :null => false
    t.integer "course_instance_id"
    t.string  "role",               :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "topic_id"
    t.string   "user_login"
    t.string   "nick"
    t.boolean  "anonymous",         :default => true
    t.boolean  "staff",             :default => false
    t.text     "text"
    t.string   "moderation_status", :default => "pending"
    t.integer  "thumbs_up",         :default => 0
    t.integer  "thumbs_down",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answer_sets", :force => true do |t|
    t.integer  "survey_id",  :null => false
    t.integer  "pseudonym"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answers", :force => true do |t|
    t.integer "survey_answer_set_id", :null => false
    t.integer "survey_question_id",   :null => false
    t.text    "answer"
  end

  create_table "survey_questions", :force => true do |t|
    t.integer "survey_id",                    :null => false
    t.integer "position",  :default => 0
    t.string  "question"
    t.string  "hint"
    t.string  "type"
    t.text    "payload"
    t.boolean "mandatory", :default => false, :null => false
    t.boolean "public",    :default => false
  end

  create_table "surveys", :force => true do |t|
    t.integer  "course_instance_id"
    t.string   "name"
    t.string   "locale"
    t.string   "answer_permission",       :default => "authenticated"
    t.string   "read_numeric_permission", :default => "authenticated"
    t.string   "read_text_permission",    :default => "staff"
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.integer  "course_instance_id",                        :null => false
    t.string   "user_login"
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
    t.string   "login",                                                      :null => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.boolean  "admin"
    t.string   "locale"
    t.integer  "thumbs_up",                               :default => 0
    t.integer  "thumbs_down",                             :default => 0
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "previous_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notify_by_email",                         :default => false
    t.datetime "last_notification_at"
  end

end
