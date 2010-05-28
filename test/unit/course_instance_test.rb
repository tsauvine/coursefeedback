require 'test_helper'

class CourseInstanceTest < ActiveSupport::TestCase
  test "create without name" do
    instance = CourseInstance.new(:name => "", :path => "spring2010")
    assert !instance.save, "Saved the instance without a name"
  end
  
  test "create without path" do
    instance = CourseInstance.new(:name => "Test course")
    assert !instance.save, "Saved the instance without a path" 
  end
  
  test "create with duplicate path" do
    CourseInstance.create(:name => "Test course 1", :path => "spring2010")
    instance = CourseInstance.new(:name => "Test course 2", :path => "spring2010")
    
    assert !instance.save, "Saved the instance with a path that already exists"
  end
  
  test "create with invalid path" do
    instance = CourseInstance.new(:name => "Test course", :path => "spring/2010")
    
    assert !instance.save, "Saved the instance with an invalid path"
  end
  
  test "sorted topics" do
    topics = sorted_topics('commented')
    
    
  end
  
end
