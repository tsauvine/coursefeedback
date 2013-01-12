# Course consists of instances such as "Spring 2010". FAQ entries belong to course because the FAQ is accumulated over the years. However, Topics and Surveys belong to CourseInstance because they reflect current events.
#
# Attributes:
# code::                      Course code, e.g. "12345"
# name::                      Course name, e.g. "Programming 101"
# feedback_read_permission::  privilege level required to read feedback sent by others
# headlines_read_permission:: privilege level required to see topic headlines
# feedback_write_permission:: privilege level required to send feedback or comments
# moderate::                  if true, new topics and messages are moderated before publishing
#
# Available privilege levels are:
# public::         Feedback is publicly visible.
# ip::             Feedback can be read from a specific IP range without authentication. The IP range is defined in config/initializers/settings.rb
# authenticated::  Authenticated users can read feedback.
# enrolled::       Only enrolled students can read feedback. NOT IMPLEMENTED
# staff::          Only teacher of the course can read feedback. In future, there might be a teaching assistant role.

class Course < ActiveRecord::Base
  has_many :course_instances, :order => 'created_at DESC', :dependent => :destroy
  has_many :faq_entries, :order => 'position DESC', :dependent => :destroy

  has_many :courseroles
  
  attr_accessible :code, :name, :feedback_read_permission, :headlines_read_permission, :feedback_write_permission, :moderate
    
  #has_many :teacher_roles, :class_name => 'Courserole', :conditions => {:role => 'teacher'} #, :primary_key => 'user_login'
  # has_many :teachers, :class_name => 'User', :finder_sql => "SELECT users.* FROM users INNER JOIN courseroles ON users.login = courseroles.user_login WHERE courseroles.course_id = #{self.id} AND courseroles.role = 'teacher' LIMIT 1"

  validates_presence_of :code
  validates_uniqueness_of :code
  validates_format_of :code, :with => URL_FORMAT_MODEL
  validates_presence_of :name

  def has_teacher?(user)
    user && Courserole.exists?(:user_id => user.id, :course_id => self.id, :role => 'teacher')
  end
end
