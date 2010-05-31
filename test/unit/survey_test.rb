require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  test "create without name" do
    survey = Survey.new(:course_instance_id => course_instances(:one), :name => '')
    assert !survey.save, "Saved the survey without a name"
  end
  
  test "open" do
    assert surveys(:open).open?
  end
  
  test "not yet open" do
    assert !surveys(:not_yet_open).open?
  end
  
  test "closed" do
    assert !surveys(:closed).open?
  end
end
