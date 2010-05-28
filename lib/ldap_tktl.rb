require 'net/ldap'

# LDAP adaptor for The Department of Computer Science at The University Of Helsinki
class LdapTktl < LdapAdaptor

  LDAP_IP = '128.214.11.5'   # IP address of the LDAP server (hostname won't work)
  LDAP_DN = "uid=%s,ou=People,dc=cs,dc=helsinki,dc=fi"
  LDAP_BASE = "dc=cs,dc=helsinki,dc=fi"

  # Authenticates the user with LDAP. Returns true if authentication succeeded.
  def authenticate(login, password)
    @ldap = Net::LDAP.new({:host => LDAP_IP, :base => LDAP_BASE, :auth => { :method => :simple, :username => LDAP_DN % login, :password => password }})

    # Authenticate
    @ldap.bind
  end

  # Fetches user information from LDAP and updates the user object. Does not save() the object. User's login attribute must be set before calling this method. Returns true if changes were made.
  def updateUser(user)
    # Return if user is nil or user.login is not set
    # Do not update information if it's already specified
    return false if !user || user.login.blank? || user.information_complete?
    
    changed = false
    
    # Bind anonymously unless we are already authenticated
    unless @ldap
      @ldap = Net::LDAP.new({:host => LDAP_IP, :base => LDAP_BASE})
    end    
    
    # Perform LDAP query
    filter = Net::LDAP::Filter.eq('uid', user.login)
    @ldap.search(:filter => filter, :attributes => 'cn') do |entry|
      # Update name
      if user.firstname.blank? && user.lastname.blank?
        name = entry.cn.first
        last_space = name.rindex(' ')
        
        if last_space == nil
          user.firstname = name
          user.lastname = ''
        else
          user.firstname = name[0..last_space-1]
          user.lastname = name[last_space+1..-1]
        end
        changed = true
      end
    end

    # Update email
    if user.email.blank?
      user.email = user.login + "@cs.helsinki.fi" 
      changed = true
    end
    
    return changed
  end
  
end

