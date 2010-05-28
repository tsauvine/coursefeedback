class MultiQuestion < SurveyQuestion

  def update_payload(params)
    alternatives = Array.new
    if params[:alternative]
      params[:alternative].each do |alt|
        alternatives << alt[1] unless alt[1].blank?
      end
    end
    
    self.payload = alternatives
  end
  
  # returns an hash with the count of each answer {question => count}
  def results
    histogram = Hash.new
    
    self.survey_answers.each do |answer|
      unless histogram[answer.answer]
        histogram[answer.answer] = 1
      else
        histogram[answer.answer] += 1
      end
    end
    
    return histogram
  end

  
end
