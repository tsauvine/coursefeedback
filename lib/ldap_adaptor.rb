# Base class for organization specific LDAP adaptors.
class LdapAdaptor
  # Authenticates a user with LDAP. Returns true if authentication succeeded.
  def authenticate(login, password)
    raise NotImplementedError
  end
  
  # Fetches user information from LDAP and updates the user object. Does not save() the object. Returns true if changes were made.
  def updateUser(user)
    raise NotImplementedError
  end
end
