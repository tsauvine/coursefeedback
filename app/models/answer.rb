#
# Answer from one user to a single question
# Note: This is not an ActiveRecord class. Answer objects are only temporarily created when reading the submitted form, and then serialized into JSON.
#
class Answer

  attr_accessor :question_id, :text, :value, :values
  attr_reader :question

  def initialize(options)
    self.question = options[:question]
  end

  # Needed to emulate ActiveRecord behavior
  def persisted?
    false
  end

  def question=(new_question)
    @question = new_question
    @question_id = new_question.id
  end

  def attributes=(attributes)
    attributes.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end

  def json_payload
    hash = {}
    hash[:text] = @text unless @text.blank?
    hash[:value] = @value unless @value.blank?
    hash[:values] = @values unless @values.blank?

    hash
  end

end
