# Course has many instances such as "Spring 2010".
# FAQ entries belong to course because the FAQ is accumulated over the years.
#
# Feedback visibility policies are defined in the following attributes:
# feedback_read_permission::   privilege level required to read feedback sent by others
# headlines_read_permission::  privilege level required to see topic headlines
# feedback_write_permission::  privilege level required to send feedback or comments
# 
# Available privilege levels are:
# public::         Feedback is publicly visible.
# ip::             Feedback can be read from a specified IP range without authentication. The IP range is defined in config/initializers/settings.rb
# authenticated::  Any authenticated user can read feedback.
# enrolled::       Enrolled students can read feedback. NOT IMPLEMENTED
# staff::          Only teacher of the course can read feedback. In future, the might be a teaching assistant role. 

class Course < ActiveRecord::Base
  has_many :course_instances, :order => 'created_at DESC', :dependent => :destroy
  has_many :faq_entries, :order => 'position DESC', :dependent => :destroy
  
  has_many :courseroles
  #has_many :teachers, :through => :courseroles, :source => :user, :conditions => {:role => 'teacher'}

  validates_presence_of :code
  validates_uniqueness_of :code
  validates_format_of :code, :with => URL_FORMAT_MODEL
  validates_presence_of :name
end
