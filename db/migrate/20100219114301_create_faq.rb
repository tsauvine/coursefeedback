class CreateFaq < ActiveRecord::Migration
  def self.up
    create_table :faq_entries do |t|
      t.references :course, :null => false
      t.integer :position, :default => 0
      t.string :caption
      t.string :question
      t.string :answer
      t.integer :thumbs_up, :default => 0
      t.integer :thumbs_down, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :faq_entries
  end
end
