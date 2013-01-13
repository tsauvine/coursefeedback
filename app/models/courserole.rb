# CourseRole connects users and courses.
#
# Attributes:
# user_id::   Login name is used to identify users so that users can be referenced even if they do not appear in the local database yet.
# course_id::    Id of the course.
# role::         Specifies the privilege level. Currently, 'teacher' is the only alternative.

class Courserole < ActiveRecord::Base 
  belongs_to :user
  belongs_to :course
  
  validates_presence_of :user_id
  validates_presence_of :course_id
  validates_presence_of :role
  
  attr_accessible :user, :course, :role
end
