class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login,                :null => false
      t.string :crypted_password,     :limit => 40
      t.string :salt,                 :limit => 40
      t.string :firstname
      t.string :lastname
      t.string :email
      t.boolean :admin
      t.string :locale
      t.integer :thumbs_up, :default => 0
      t.integer :thumbs_down, :default => 0
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.timestamp :last_login_at
      t.timestamp :previous_login_at
      t.timestamps
    end
    
    create_table :courses do |t|
      t.string :code,                 :null => false
      t.string :name
      t.string :headlines_read_permission, :default => 'authenticated'  # public, ip, authenticated, enrolled, staff
      t.string :feedback_read_permission, :default => 'authenticated'   # public, ip, authenticated, enrolled, staff
      t.string :feedback_write_permission, :default => 'authenticated'  # public, ip, authenticated, enrolled
      t.boolean :moderate, :default => false
      t.timestamps
    end
    
    create_table :course_instances do |t|
      t.references :course,           :null => false
      t.integer :position, :default => 0
      t.string :name
      t.string :path,                 :null => false
      t.boolean :active, :default => true
      t.timestamps
    end
    
    create_table :topics do |t|
      t.references :course_instance, :null => false
      t.string :user_login
      t.string :nick
      t.boolean :anonymous, :default => true
      t.string :caption
      t.string :visibility, :default => 'public'  # staff, public
      t.text :text
      t.string :moderation_status, :default => 'pending' # pending, published, censored, deleted
      t.string :action_status   # answered
      t.integer :thumbs_up, :default => 0
      t.integer :thumbs_down, :default => 0
      t.timestamp :commented_at
      t.timestamps
    end
    
    create_table :messages do |t|
      t.references :topic
      t.string :user_login
      t.string :nick
      t.boolean :anonymous, :default => true
      t.boolean :staff, :default => false
      t.text :text
      t.string :moderation_status, :default => 'pending' # pending, published, censored, deleted
      t.integer :thumbs_up, :default => 0
      t.integer :thumbs_down, :default => 0
      t.timestamps
    end
    
    #, :id => false
    create_table :courseroles do |t|
      t.string :user_login, :null => false
      t.references :course
      t.string :role, :null => false
    end
    
    create_table :instanceroles do |t|
      t.string :user_login, :null => false
      t.references :course_instance
      t.string :role, :null => false
    end
  end

  def self.down
    drop_table :instanceroles
    drop_table :courseroles
    drop_table :messages
    drop_table :topics
    drop_table :course_instances
    drop_table :courses
    drop_table :users
  end
end
