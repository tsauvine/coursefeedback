require 'test_helper'

class FaqTest < ActiveSupport::TestCase
  test "create without caption" do
    entry = FaqEntry.new(:course_id => courses(:one).id, :caption => '')
    assert !entry.save, "Saved the FAQ entry without a caption"
  end
  
  test "create without question" do
    entry = FaqEntry.new(:course_id => courses(:one).id, :caption => 'No question', :question => '', :answer => 'Answer')
    assert entry.save, "Refused to save FAQ entry without question"
  end
  
  test "create without answer" do
    entry = FaqEntry.new(:course_id => courses(:one).id, :caption => 'No answer', :question => 'Question', :answer => '')
    assert entry.save, "Refused to save FAQ entry without answer"
  end
  
end
