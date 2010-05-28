class SurveyAnswerSet < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_answers, :dependent => :destroy
  
  serialize :answer

end
