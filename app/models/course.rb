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
