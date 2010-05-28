# Palaute

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  layout 'tktl'

  # SSL
  #before_filter :redirect_to_ssl
  def redirect_to_ssl
    redirect_to :protocol => "https://" if ENABLE_SSL && !request.ssl?
  end

  # Locale
  before_filter :set_locale
  def set_locale
    #I18n.load_path << Dir[File.join(RAILS_ROOT, 'config', 'locales', controller_name, '*.{rb,yml}')]

    if params[:locale]  # Locale is given as a URL parameter
      I18n.locale = params[:locale]
      
      # Save the locale into session
      session[:locale] = params[:locale]

      # Save the locale in user's preferences
      if logged_in?
        current_user.locale = params[:locale]
        current_user.save
      end
    elsif logged_in? && !current_user.locale.blank?  # Get locale from user's preferences
      I18n.locale = current_user.locale
    elsif !session[:locale].blank?  # Get locale from session
      I18n.locale = session[:locale]
    end
  end
  
  # CSS
  before_filter :load_css
  def load_css
    @stylesheets = ['default']
    
    # If directory exists
    if File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', controller_name + '.css'))
      @stylesheets << controller_name
    end
  end
  
  # Login
  # If require_login parameter is set, this filter will store location and redirect to login. After successful login, the user is redirected back to original location.
  before_filter :require_login?
  def require_login?
    if params[:require_login] && !logged_in?
      store_location
      redirect_to new_session_path
    end
  end


  protected
  
  # Send email on exception
  def log_error(exception)
    super(exception)

    begin
      # Send email
      if ERRORS_EMAIL && !(local_request? || exception.is_a?(ActionController::RoutingError))
        ErrorMailer.deliver_snapshot(exception, clean_backtrace(exception), params, request)
      end
    rescue => e
      logger.error(e)
    end
  end

end
