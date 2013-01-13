#
# Answers from one user to a questionnaire
# payload is JSON that looks like: { <question_id>: {value: 3, text: 'Some feedback'}, <question_id>: {...}, ...  ]
#
class AnswerSet < ActiveRecord::Base
  belongs_to :user
  belongs_to :questionnaire

  attr_reader :answers

  #
  # Populates the answer_set with answer objects so that the form can be shown
  #
  def init_questionnaire(questionnaire)
    @answers = []

    questionnaire.questions.each do |question, index|
      # Create an appropriate Answer object based on question.type, e.g. if question.type == 'DefaultQuestion' then DefaultAnswer.new
      answer = Object::const_get("#{question.type[0..-9]}Answer").new(:question => question)

      @answers << answer
    end
  end

  def questionnaire_id=(id)
    write_attribute('questionnaire_id', id)
    init_questionnaire(Questionnaire.find(id))
  end

  #
  # Called when the form is submitted. Creates Answer objects from the form fields.
  #
  def answers_attributes=(attributes)
    new_payload = {}

    attributes.each do |index, values|
      answer = @answers[index.to_i]
      raise 'Question not found' unless answer

      answer.attributes = values

      new_payload[answer.question_id] = answer.json_payload
    end

    self.payload = new_payload.to_json
  end

  def payload
    JSON.parse(read_attribute(:payload))
  end

end
