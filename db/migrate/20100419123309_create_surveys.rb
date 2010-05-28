class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.references :course_instance
      t.string :name
      t.string :locale
      t.string :answer_permission, :default => 'authenticated'   # public, ip, authenticated, enrolled, staff
      t.string :read_numeric_permission, :default => 'authenticated'
      t.string :read_text_permission, :default => 'staff'
      t.timestamp :opens_at
      t.timestamp :closes_at
      t.timestamps
    end
    
    create_table :survey_questions do |t|
      t.references :survey, :null => false
      t.integer :position, :default => 0
      t.string :question
      t.string :hint
      t.string :type    # StringQuestion, TextQuestion, RadioQuestion, CheckboxQuestion, DropdownQuestion, LikertQuestion
      t.text :payload
      t.boolean :mandatory, :null => false, :default => false
      t.boolean :public, :default => false
      
    end

    create_table :survey_answer_sets do |t|
      t.references :survey, :null => false
      t.integer :pseudonym
      t.timestamps
    end
    
    create_table :survey_answers do |t|
      t.references :survey_answer_set, :null => false
      t.references :survey_question, :null => false
      t.text :answer
    end
  end

  def self.down
    drop_table :survey_answers
    drop_table :survey_answer_sets
    drop_table :survey_questions
    drop_table :surveys
  end
end
