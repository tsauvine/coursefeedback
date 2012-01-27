class SessionsController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])

    session[:logout_url] = nil

    if @session.save
      logger.info "Login successful"
      redirect_back_or_default root_url
    else
      logger.info "Login failed. #{@session.errors.full_messages.join(',')}"
      render :action => :new
    end
  end

  def destroy
    logout_url = session[:logout_url]

    session = current_session
    return unless session

    session.destroy
    flash[:success] = "Logout successful"

    if logout_url
      redirect_to(logout_url)
    else
      redirect_to(root_url)
    end
  end


  def shibboleth
    shibinfo = {
      :login => request.env['HTTP_EPPN'],
      :studentnumber => (request.env['HTTP_SCHACPERSONALUNIQUECODE'] || '').split(':').last,
      :name => "#{request.env['HTTP_DISPLAYNAME']} #{request.env['HTTP_SN']}",
      :email => request.env['HTTP_MAIL'],
    }
    logout_url = request.env['HTTP_LOGOUTURL']

#     shibinfo = {
#       :login => 'student1@hut.fi', #'student1@hut.fi',
#       :studentnumber => ('urn:mace:terena.org:schac:personalUniqueCode:fi:tkk.fi:student:20001' || '').split(':').last,
#       :name => 'Teemu Teekkari',
#       :email => 'tteekkar@cs.hut.fi',
#     }
#     logout_url= 'http://www.aalto.fi/'

    shibboleth_login(shibinfo, logout_url)
  end


  def shibboleth_login(shibinfo, logout_url)
    if shibinfo[:login].blank? && shibinfo[:studentnumber].blank?
      flash[:error] = "Shibboleth login failed. No username or studentnumber was received."
      logger.warn("Shibboleth login failed (missing attributes). #{shibinfo}")
      render :action => 'new'
      return
    end

    # Find user by username (eppn)
    unless shibinfo[:login].blank?
      logger.debug "Trying to find by login #{shibinfo[:login]}"
      user = User.find_by_login(shibinfo[:login])
    end

    # If user was not found by login, search with student number. (User may have been created as part of a group, but has never actually logged in.)
    # Login must be null, otherwise the account may belong to someone else from another organization.
    #if !user && !shibinfo[:studentnumber].blank?
    #  logger.debug "Trying to find by studentnumber #{shibinfo[:studentnumber]}"
    #  user = User.find_by_studentnumber(shibinfo[:studentnumber], :conditions => "login IS NULL")
    #end

    # Create new account or update an existing
    unless user
      logger.debug "User not found. Trying to create."

      # New user
      user = User.new(shibinfo)
      user.login = shibinfo[:login]
      user.studentnumber = shibinfo[:studentnumber]
      user.reset_persistence_token
      user.reset_single_access_token
      if user.save(:validate => false) # Don't validate because Authlogic would complain about missing password.
        logger.info("Created new user #{user.login} (#{user.studentnumber}) (shibboleth)")
      else
        logger.info("Failed to create new user (shibboleth) #{shibinfo} Errors: #{user.errors.full_messages.join('. ')}")
        flash[:error] = "Failed to create new user. #{user.errors.full_messages.join('. ')}"
        render :action => 'new'
        return
      end
    else
      logger.debug "User found. Updating attributes."

      # Update metadata
      shibinfo.each do |key, value|
        user.write_attribute(key, value) if user.read_attribute(key).blank?
      end

      user.reset_persistence_token if user.persistence_token.blank?  # Authlogic won't work if persistence token is empty
      user.reset_single_access_token if user.single_access_token.blank?
      #user.save
    end

    # Create session
    if Session.create(user)
      session[:logout_url] = logout_url
      logger.info("Logged in #{user.login} (#{user.studentnumber}) (shibboleth)")

      redirect_back_or_default root_url
    else
      logger.warn("Failed to create session for #{user.login} (#{user.studentnumber}) (shibboleth)")
      flash[:error] = 'Shibboleth login failed.'
      render :action => 'new'
    end
  end
end
