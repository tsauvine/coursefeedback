class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :studentnumber
    #c.validate_password_field = false
    c.validate_email_field = false
  end

  validates_uniqueness_of :login, :allow_nil => true
  attr_accessible :email, :name, :locale, :password, :password_confirmation, :remember_me, :notify_by_email

  delegate :can?, :cannot?, :to => :ability
  
  #has_many :courses_as_teacher, :through => :courseroles, :source => :course, :conditions => {:role => 'teacher'}, :primary_key => 'login', :foreign_key => 'user_login'


  # Returns the name of the user
#   def name
#     if name.blank?
#       return self.name
#     else
#       return self.login
#     end
#   end

  def admin?
    self.admin
  end

end
