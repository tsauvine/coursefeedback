require 'test_helper'

class CourseInstanceTest < ActiveSupport::TestCase
  test "create without name" do
    instance = CourseInstance.new(:course_id => courses(:one), :name => "", :path => "spring2010")
    assert !instance.save, "Saved the instance without a name"
  end
  
  test "create without path" do
    instance = CourseInstance.new(:course_id => courses(:one), :name => "Test instance")
    assert !instance.save, "Saved the instance without a path" 
  end
  
  test "create with duplicate path" do
    CourseInstance.create(:course_id => courses(:one), :name => "Test instance 1", :path => "spring2010")
    instance = CourseInstance.new(:course_id => courses(:one), :name => "Test instance 2", :path => "spring2010")
    
    assert !instance.save, "Saved the instance with a path that already exists"
  end
  
  test "duplicate path scope" do
    CourseInstance.create(:course_id => courses(:one).id, :name => "Test instance 1", :path => "spring2010")
    instance = CourseInstance.new(:course_id => courses(:two).id, :name => "Test instance 2", :path => "spring2010")
    
    assert instance.save, "Failed to save the instance when another course has an instance with a similar path"
  end
  
  test "create with invalid path" do
    instance = CourseInstance.new(:course_id => courses(:one), :name => "Test course", :path => "spring/2010")
    
    assert !instance.save, "Saved the instance with an invalid path"
  end
  
  test "public sorted topics should not contain private topics" do
    topics = course_instances(:one).sorted_topics('date')
    
    topics.each do |topic|
      assert topic.visibility == 'public', "Topic list contains private topics"
    end
  end
    
  
end
