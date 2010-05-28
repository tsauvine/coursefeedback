class SurveyQuestion < ActiveRecord::Base
  acts_as_list :scope => :survey
  
  belongs_to :survey
  has_many :survey_answers
  
  serialize :payload

  # Parses params from the HTML form and updates the question.
  # used when editing the surevy
  def update_payload(params)
  end
  
  # Parses params from the HTML form and updates the answer object.
  # Used when answering the survey.
  def update_answer(answer, params)
    answer.answer = params
  end
  
  def results
    self.survey_answers
  end

end
