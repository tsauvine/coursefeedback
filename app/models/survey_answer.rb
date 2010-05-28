class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_answer_set
  belongs_to :survey_question
  
  serialize :answer
  
end
