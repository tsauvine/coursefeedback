class CreateAuthlogic < ActiveRecord::Migration
  def self.up
    #drop_table :users

    # Switch to Authlogic
    create_table :users do |t|
      t.string    :login
      t.string    :studentnumber
      t.string    :name
      t.string    :email
      t.string    :crypted_password
      t.string    :password_salt
      t.boolean   :admin,               :default => false
      t.string    :persistence_token,   :null => false
      t.string    :single_access_token, :null => false
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
    end
    add_index :users, :login
    add_index :users, :persistence_token
    add_index :users, :last_request_at


    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def self.down
    drop_table :sessions
    drop_table :users

#     create_table(:users) do |t|
#       t.string :login, :null => false
#       t.string :studentnumber
#       t.string :name
#       t.string :email
#       t.database_authenticatable
#       t.recoverable
#       t.rememberable
#       t.trackable
#       t.string :locale,                    :default => 'fi', :limit => 5
#       t.boolean :admin, :default => false
#       t.timestamps
#     end
  end
end
