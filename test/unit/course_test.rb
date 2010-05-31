require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "create without name" do
    course = Course.new(:name => "", :code => "12345")
    assert !course.save, "Saved the course without a name"
  end
  
  test "create without code" do
    course = Course.new(:name => "Test course")
    assert !course.save, "Saved the course without a code"
  end
  
  test "create with duplicate code" do
    Course.create(:name => "Test course 1", :code => "12345")
    course = Course.new(:name => "Test course 2", :code => "12345")
    
    assert !course.save, "Saved the course with a code that already exists"
  end
  
  test "create with invalid code" do
    course = Course.new(:name => "Test course", :code => "T/1001")
    
    assert !course.save, "Saved the course with an invalid code"
  end
end
