module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    # Accesses the current user from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    def is_admin?(user)
      user && user.admin
    end
    
    # Checks if user has teacher's role on the specified course.
    # If course is :any, checks if user has teacher's role on any course.
    # If user or course is nil, false is returned.
    # Returns true if user has teacher's role.
    def is_teacher?(user, course)
      return false unless user and course
      
      if course == :any
        Courserole.exists?(:user_login => user.login, :role => 'teacher')
      else
        Courserole.exists?(:user_login => user.login, :course_id => course.id, :role => 'teacher')
      end
    end
    
    # Returns true if user has the specified privilege level on the specified course.
    # Possible levels are: public, ip, authenticated, enrolled, staff
    # 
    # public: any unauthenticated visitor
    # ip: request must come from the trusted network range (defined as NETWORK_RANGE, see config/initializers/settings.rb)
    # authenticated: user must have logged in
    # enrolled: user must be a student on the specified course
    # staff: user must be a teacher on the specified course
    def authorized_level?(user, course, level)
      case level
        when 'public'
          return true
        when 'ip'
          return trusted_ip_range?() || logged_in?
        when 'authenticated'
          return logged_in?
        when 'enrolled':
          return is_teacher?(current_user, course) # TODO: enrolled students
        when 'staff':
          return is_teacher?(current_user, course)
      end
    
      logger.error "Unknown privilege level: #{level}"
    
      return false
    end
    
    # Checks that user has one of the specified roles.
    # Example: put "authorize(:admin, :teacher) or return" in the beginning of a controller method to athorize admins and teachers.
    # Possible values: :teacher, :admin
    #
    # If user is not authenticated, redirects to login, then back to current view.
    # If user is authenticated but lacks the required privilege level, the "Forbidden view" is rendered.
    #
    # Returns true if user has one of the specified roles
    def authorize(*roles)
      # Redirect to login if not logged in
      unless logged_in?
        store_location
        redirect_to new_session_path
        return false
      end
      
      # Check if user has the required role
      roles.each do |role|
        case role
          when :admin
            return true if is_admin?(current_user)
          when :teacher
            return true if is_teacher?(current_user, @course)
        end
      end
      
      access_denied
    end
    
    # Checks that user has required privilege level on current course (@course)
    # Example: put "authorize_level('enrolled') or return" in the beginning of a controller method.
    # Possible levels: public, ip, authenticated, enrolled, staff
    #
    # If user is not authenticated, redirects to login, then back to current view.
    # If user is authenticated but lacks the required privilege level, the "Forbidden view" is rendered.
    #
    # Returns true if user has the required level
    def authorize_level(level)
      authorized_level?(current_user, @course, level) || access_denied
    end

    # Checks that user is authenticated. If not, redirects to login page, then back.
    # Returns true if user is authenticated.
    def authorize_authenticated
      logged_in? || access_denied
    end
    
    # Checks that user has teacher's role on current course (@course).
    # If user is not authenticated, redirects to login. If user is authenticated but does not have teacher's role, renders "Forbidden".
    # Returns true if user is authenticated and is teacher on the current course.
    def authorize_teacher
      is_teacher?(current_user, @course) || is_admin?(current_user) || access_denied
    end
    
    def authorize_admin
      is_admin?(current_user) || access_denied
    end


    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      if request.xhr?
        head :forbidden
        return
      end
      
      if logged_in?
        # If already logged in, show 'forbidden'
        render :template => "shared/forbidden", :status => 403
      else
        # If not logged in, redirect to login
        respond_to do |format|
          format.html do
            store_location
            redirect_to new_session_path
          end
          format.any do
            request_http_basic_authentication 'Web Password'
          end
        end
      end
      
      return false
    end
    
    # Returns true if the request is coming from the trusted IP range (defined as NETWORK_RANGE, see config/initializers/settings.rb).
    # Localhost is always considered trusted.
    def trusted_ip_range?()
      return false unless NETWORK_RANGE

      remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
      address = IPAddr.new(remote_ip.split(',').first.strip)
      
      IPAddr.new('127.0.0.0/8').include?(address) || IPAddr.new(NETWORK_RANGE).include?(address)
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :is_admin?, :authorized_level?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
end
