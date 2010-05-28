class Survey < ActiveRecord::Base
  belongs_to :course_instance
  has_many :survey_questions, :order => 'position ASC', :dependent => :destroy
  has_many :survey_answer_sets, :dependent => :destroy
  
  validates_presence_of :name
  
  def open?
    self.opens_at < Time.now && self.closes_at > Time.now
  end
  
end
