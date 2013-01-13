class Question < ActiveRecord::Base

  attr_accessor :sums, :answer_counter

  after_initialize do
    # Statistics counters
    @sums = {}            # value => frequency
    @answer_counter = 0
  end

  # Default statistics counter
  # This method called once for each answer, and it updates @sums and @answer_counter
  def calculate_statistics(answer_payload)
    # Questions with a single value in answer
    value = answer_payload['value']
    if value
      @sums[value] ||= 0
      @sums[value] += 1

      @answer_counter += 1
    end

    # Questions with multiple values in answer
    values = answer_payload['values']
    if values
      values.each do |value|
        @sums[value] ||= 0
        @sums[value] += 1
      end

      @answer_counter += 1
    end
  end

  # Returns the median answer. This is only available after calling calculate_statistics(). Nil is returned if the result is not available.
  def median
    return nil if @answer_counter < 1

    # Calculate median
    midpoint = @answer_counter / 2
    acc = 0
    @sums.each do |value, freq|
      acc += freq
      return value if acc >= midpoint
    end
  end

  def payload
    return unless read_attribute(:payload)
    JSON.parse(read_attribute(:payload))
  end

  def as_json(options={})
    super(options.merge(:only => [:id, :text, :hint, :params], :methods => [:type, :payload]))
  end

end
