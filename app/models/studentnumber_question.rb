class StudentnumberQuestion < SurveyQuestion
  
  def results
    studentnumbers = Array.new
    
    self.survey_answers.each do |answer|
      studentnumbers << answer.answer unless answer.answer.blank?
    end
    
    studentnumbers.sort
  end
  
end
