class AddEmailNotifications < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_by_email, :boolean, :default => true
    add_column :users, :last_notification_at, :timestamp
  end

  def self.down
    remove_column :users, :notify_by_email
    remove_column :users, :last_notification_at
  end
end
