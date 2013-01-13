# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_session, :current_user, :logged_in?, :user_signed_in?

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :redirect_to_ssl
  before_filter :set_locale
  # before_filter :load_css
  before_filter :require_login?

  # Redirects from http to https if ENABLE_SSL is set.
  def redirect_to_ssl
    redirect_to :protocol => "https://" if ENABLE_SSL && !request.ssl?
  end

  # Sets the locale based on params and user preferences.
  def set_locale
    #I18n.load_path << Dir[File.join(RAILS_ROOT, 'config', 'locales', controller_name, '*.{rb,yml}')]

    if params[:locale]  # Locale is given as a URL parameter
      I18n.locale = params[:locale]

      # Save the locale into session
      session[:locale] = params[:locale]

      # Save the locale in user's preferences
#       if current_user
#         current_user.locale = params[:locale]
#         current_user.save
#       elsif current_user && !current_user.locale.blank?  # Get locale from user's preferences
#         I18n.locale = current_user.locale
    elsif !session[:locale].blank?  # Get locale from session
      I18n.locale = session[:locale]
    end
  end

  # Loads extra CSS stylesheets.
#   def load_css
#     @stylesheets = ['default']
#
#     # If directory exists
#     if File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', controller_name + '.css'))
#       @stylesheets << controller_name
#     end
#   end


  protected

  # Sends email to admin if an exception occurrs. Recipient is defined by the ERRORS_EMAIL constant.
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

  # Handle authorization failure
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      # If user is authenticated, show "Forbidden"
      render :template => "shared/forbidden", :status => 403
    else
      # If user is not authenticated, redirect to login
      login_required
    end
  end


  def current_session
    return @current_session if defined?(@current_session)
    @current_session = Session.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_session && current_session.record
  end

  def user_signed_in?
    !current_user.nil?
  end
  alias :logged_in? :user_signed_in?

  # If require_login GET-parameter is set, this filter redirect to login. After successful login, the user is redirected back to the original location.
  def require_login?
    login_required if params[:require_login] && !user_signed_in?
  end

  def login_required
    unless current_user
      store_location

      # TODO: make this configurable
      #redirect_to new_session_url
      if request.env[SHIB_ATTRIBUTES[:id]]
        # If Shibboleth headers are present, redirect directly to session creation
        redirect_to shibboleth_session_path
      else
        # If Shibboleth headers are not present, redirect directly to IdP
        redirect_to "/Shibboleth.sso/aalto?target=" + shibboleth_session_url(:protocol => 'https')
      end

      return false
    end
  end

#   def access_denied
#     if request.xhr?
#       head :forbidden
#     elsif logged_in?
#       render :template => 'shared/forbidden', :status => 403
#     else
#       # If not logged in, redirect to login
#       respond_to do |format|
#         format.html do
#           store_location
#           redirect_to new_session_path
#         end
#         format.any do
#           request_http_basic_authentication 'Web Password'
#         end
#       end
#     end
#
#     return false
#   end
#
# #   def require_no_user
# #     if current_user
# #       store_location
# #
# #       flash[:error] = "You must be logged out to access"
# #       redirect_to root_url
# #
# #       return false
# #     end
# #   end
#
  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
