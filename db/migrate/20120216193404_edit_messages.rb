class EditMessages < ActiveRecord::Migration
  def up
    add_column :messages, :edited_at, :timestamp
    add_column :messages, :editor_login, :string
    add_column :messages, :edit_reason, :text
  end

  def down
    remove_column :messages, :edited_at
    remove_column :messages, :editor_login
    remove_column :messages, :edit_reason
  end
end
