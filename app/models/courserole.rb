# CourseRole connects users and courses.
#
# Attributes:
# user_login::   Login name is used to identify users so that users can be referenced even if they do not appear in the local database yet.
# course_id::    Id of the course.
# role::         Specifies the privilege level. Currently, 'teacher' is the only alternative.

class Courserole < ActiveRecord::Base 
  belongs_to :user, :primary_key => 'login', :foreign_key => 'user_login'
  belongs_to :course
end
