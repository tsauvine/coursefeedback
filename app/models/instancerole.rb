# Connects Users and CourseInstances.
# RESERVED FOR FUTURE USE
class Instancerole < ActiveRecord::Base 
  belongs_to :user
  belongs_to :course

end
