require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  
  test "add thumbs up" do
    assert_difference('messages(:published).thumbs_up', 1) do
      assert_difference('messages(:published).thumbs_down', 0) do
        messages(:published).add_thumb_up
      end 
    end
  end
  
  test "add thumbs down" do
    assert_difference('messages(:published).thumbs_up', 0) do
      assert_difference('messages(:published).thumbs_down', 1) do
        messages(:published).add_thumb_down
      end 
    end
  end
  
end
