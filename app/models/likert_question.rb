class LikertQuestion < SurveyQuestion
  
  def update_payload(params)
    scale = Array.new
    if params[:likertscale]
      params[:likertscale].each do |alt|
        # params[:likertscale] contains arrays [id, value]
        scale << alt[1] unless alt[1].blank?
      end
    end
    
    questions = Array.new
    if params[:likertquestion]
      params[:likertquestion].each do |alt|
        questions << alt[1] unless alt[1].blank?
      end
    end
    
    self.payload = [scale,questions]
  end
  
  def update_answer(answer, params)
    answers = Array.new
    
    if params
      params.each do |row|
        answers[row[0].to_i] = row[1]
      end
    end

    answer.answer = answers
  end
  
  # returns an hash of arrays {question => [scale => count] }
  def results
    histogram = Hash.new
    
    questions = self.payload[1]
    
    questions.each_with_index do |question, index|
      unless histogram[question]
        histogram[question] = Array.new
      end
      
      self.survey_answers.each do |answer|
        next unless answer.answer[index]
        
        answer_index = answer.answer[index].to_i
        
        unless histogram[question][answer_index]
          histogram[question][answer_index] = 1
        else
          histogram[question][answer_index] += 1
        end
      end
    end
    
    return histogram
  end

end
