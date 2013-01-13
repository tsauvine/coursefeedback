class Orientation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_instance
  
end
