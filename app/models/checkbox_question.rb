class CheckboxQuestion < MultiQuestion
  
  def update_answer(answer, params)
    answers = Array.new

    if params
      params.each do |row|
        answers << row[1]
      end
    end

    answer.answer = answers
  end
  
  # returns an array with the number of each answer
  def results
    histogram = Hash.new
    
    self.survey_answers.each do |answer|
      next unless answer.answer
      
      logger.info "1d array: #{answer.answer}"
      answer.answer.each do |a|
        logger.info "atomic answer: #{a}"
  
        unless histogram[a]
          histogram[a] = 1
        else
          histogram[a] += 1
        end
      end
    end
    
    return histogram
  end
  
end
