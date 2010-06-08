require 'digest/sha1'

#
class User < ActiveRecord::Base
  
  #has_many :courses_as_teacher, :through => :courseroles, :source => :course, :conditions => {:role => 'teacher'}, :primary_key => 'login', :foreign_key => 'user_login'
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  #validates_presence_of     :email
  #validates_presence_of     :password,                   :if => :password_required?
  #validates_presence_of     :password_confirmation,      :if => :password_required?
  #validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :notify_by_email

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # Get an LdapAdaptor if one is defined
    ldapAdaptor = LDAP_ADAPTOR != nil ? Object::const_get(LDAP_ADAPTOR).new() : nil
    
    # Authenticate first with LDAP, then fall back to password
    if ldapAdaptor && ldapAdaptor.authenticate(login,password)
      user = find_by_login(login)
      
      # Create a new user if necessary
      user ||= User.new(:login => login)

      ldapAdaptor.updateUser(user) && user.save(false)
    else
      # Authenticate with password
      user = find_by_login(login) # need to get the salt
      return nil unless user && user.authenticated?(password)
    end
    
    return user
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Checks password validity
  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # Returns true if the 'remember me' token is still valid.
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  # Sets the 'remember me' token
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  # Sets the 'remember me' token
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  # Invalidated the 'remember me' token
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  # Returns the name of the user 'Firstname Lastname'
  def name
    if !firstname.blank? && !lastname.blank?
      return "#{firstname} #{lastname}"
    elsif !firstname.blank?
      return firstname
    elsif !lastname.blank?
      return lastname
    else 
      return login
    end
  end
  
  # Returns true if all the relevant information about the user (name, email) is defined
  def information_complete?
    return !(firstname.blank? || lastname.blank? || email.blank?)
  end

  # Returns true if the admin flag is set
  def is_admin?
    self.admin
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
   
end
