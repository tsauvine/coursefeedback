class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  acts_as_authentic do |c|
    c.login_field = :studentnumber
    c.validate_password_field = false
    c.validate_email_field = false
  end

  validates_uniqueness_of :login, :allow_nil => true

  attr_accessible :login, :email, :name, :locale, :password, :password_confirmation, :remember_me, :notify_by_email

  #has_many :courses_as_teacher, :through => :courseroles, :source => :course, :conditions => {:role => 'teacher'}, :primary_key => 'login', :foreign_key => 'user_login'


  # Returns the name of the user
#   def name
#     if name.blank?
#       return self.name
#     else
#       return self.login
#     end
#   end

  # Returns true if all the relevant information about the user (name, email) is defined
  def information_complete?
    return !(name.blank? || email.blank?)
  end

  def admin?
    self.admin
  end

end
