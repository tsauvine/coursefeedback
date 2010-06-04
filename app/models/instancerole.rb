# Connects Users and CourseInstances.
# RESERVED FOR FUTURE USE
class Instancerole < ActiveRecord::Base 
  belongs_to :user, :primary_key => 'login', :foreign_key => 'user_login'
  belongs_to :course

end
