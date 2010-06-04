require 'test_helper'

class TopicTest < ActiveSupport::TestCase
 
  test "add thumbs up" do
    assert_difference('topics(:public).thumbs_up', 1) do
      assert_difference('topics(:public).thumbs_down', 0) do
        topics(:public).add_thumb_up
      end 
    end
  end
  
  test "add thumbs down" do
    assert_difference('topics(:public).thumbs_up', 0) do
      assert_difference('topics(:public).thumbs_down', 1) do
        topics(:public).add_thumb_down
      end 
    end
  end
  
  test "empty caption" do
    assert !topics(:without_caption).caption.empty?, "Caption is empty (should show beginning of message)"
  end
  
  
  test "find answer (exists)" do
    answer = topics(:public).find_answer
    
    assert_not_nil answer
    assert answer.staff == true, "find_answer returned a message that is not from staff"
  end
  
  test "find answer (does not exist)" do
    answer = topics(:moderated_pending).find_answer
    
    assert_nil answer
  end
  
end
