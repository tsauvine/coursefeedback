#
# payload is JSON that looks like "{ question_ids: [1, 2, 3] }"
#
class Questionnaire < ActiveRecord::Base
  belongs_to :race_instance
  has_many :answer_sets

  after_create :add_default_questions

  #
  # Makes the content of this questionnaire identical to the default questionnaire.
  #
  def add_default_questions
    default_questionnaire = Questionnaire.find(1)  # FIXME: some clever way to identify the default questionnaire

    self.payload = default_questionnaire.payload
    save!
  end

#   def to_json
#     questions = []
#
#     self.questionnaire_questions.each do |qq|
#       questions << {questionnaire_question_id: qq.id, question_id: qq.question.id, type: qq.question.type, text: qq.question.text, content: qq.question.content, position: qq.position}
#     end
#
#     questions
#   end


  def load_JSON(json, user)
    new_content = JSON.parse(json)

    logger.info "JSON: #{json}"
    logger.info new_content.inspect

    ids = []

    # Create new questions and update existing ones
    inserts = []
    updates = []
    new_content.each do |raw_question|
      id = Integer(raw_question['id']) rescue false

      if id
        # Existing question
        question = Question.find(id)
      else
        # New question
        question = case raw_question['type']
          when 'RateQuestion' then RateQuestion.new
          when 'TextfieldQuestion' then TextfieldQuestion.new
          when 'TextareaQuestion' then TextareaQuestion.new
          when 'RadioQuestion' then RadioQuestion.new
          when 'CheckboxQuestion' then CheckboxQuestion.new
          else DefaultQuestion.new
        end

        question.questionnaire_id = self.id
      end

      # Authorize edit
      if user.can? :edit, question # TODO: & raw_question['modified']
        question.type = raw_question['type']
        question.hint = raw_question['hint']
        question.params = raw_question['params']
        question.text = raw_question['text']

        if raw_question['payload']
          question.payload = raw_question['payload'].to_json
        else
          question.payload = nil
        end

        question.save!
      end

      ids << question.id
    end

    # Update the list of questions that are used in this questionnaire
    self.payload = {question_ids: ids}.to_json
    save!
  end


  #
  # This runs in O(N). Results are cached in self.summary in JSON that looks like: {<question_id_1>: {median: 4.5}}, ...}
  #
  def calculate_summary
    # Load questions into  a hash (question_id => Question)
    questions = self.questions_hash()

    # Iterate through answer_sets
    self.answer_sets.find_each do |answer_set|
      answer_set.payload.each do |question_id, answer_payload|
        # Load question
        question = questions[question_id.to_i]
        next unless question

        # Report values to question
        question.calculate_statistics(answer_payload)
      end
    end

    # Collect results
    summaries = {}
    questions.each do |question_id, question|
      median = question.median
      next unless median

      summaries[question_id] = {median: median}
    end

    self.summary = summaries.to_json
    self.save!
  end

  # Returns a hash: {<question_id_1>: {median: 4.5}, ...}
  def summary
    @summary ||= JSON.parse(read_attribute(:summary))
  end

  # Returns the number of answers to this questionnaire
  def answers_count
    self.answer_sets.size
  end

  # Returns an array of comments: {question: {text: 'Question?'}, comments: ['comment1', 'comment2']}
  def comments(question_id)
    question = Question.find(question_id)
    comments = []

    self.answer_sets.find_each do |answer_set|
      answer = answer_set.payload[question_id.to_s]
      next unless answer

      comments << answer['text'] if answer['text']
    end

    {question: {text: question.text}, comments: comments}
  end

  #
  # Returns an array of Question objects used in this questionnaire
  #
  def questions
    questions_hash = self.questions_hash()
    questions = []

    self.question_ids.each do |question_id|
      questions << questions_hash[question_id]
    end

    questions
  end

  #
  # Returns Questions in a hash: question_id => Question
  #
  def questions_hash
    questions = {}

    Question.where(:id => question_ids).find_each do |question|
      questions[question.id] = question
    end

    questions
  end

  #
  # Returns ids of the Questions used in this questionnaire
  #
  def question_ids
    # Parse payload
    json = JSON.parse(self.payload)['question_ids']
  end


  # { <question_id_1>: {}}
#   def to_json(*a)
#     questions = {}
#     self.questions.each do |question|
#       questions[question.id] = question
#     end
#
#     questions.to_json(*a)
#   end



end
