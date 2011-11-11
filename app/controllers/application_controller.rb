# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #include Authorization

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  #layout 'tktl'

  before_filter :redirect_to_ssl
  before_filter :set_locale
  before_filter :load_css
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
      if user_signed_in?
        current_user.locale = params[:locale]
        current_user.save
      end
      elsif user_signed_in? && !current_user.locale.blank?  # Get locale from user's preferences
        I18n.locale = current_user.locale
      elsif !session[:locale].blank?  # Get locale from session
        I18n.locale = session[:locale]
    end
  end

  # Loads extra CSS stylesheets.
  def load_css
    @stylesheets = ['default']

    # If directory exists
    if File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', controller_name + '.css'))
      @stylesheets << controller_name
    end
  end

  # If require_login GET-parameter is set, this filter redirect to login. After successful login, the user is redirected back to the original location.
  def require_login?
    authenticate_user! if params[:require_login] && !user_signed_in?
  end


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
    unless user_signed_in?
      # If user is not authenticated, redirect to login
      authenticate_user!
    else
      # If user is authenticated, show "Forbidden"
      render :template => "shared/forbidden", :status => 403
    end
  end

end
