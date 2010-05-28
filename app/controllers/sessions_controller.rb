# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :redirect_to_ssl

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    
    if logged_in?
      # Stay logged?
      if params[:remember_me] == '1'
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      
      # Update timestamps
      current_user.previous_login_at = current_user.last_login_at
      current_user.last_login_at = Time.now
      current_user.save
      

      redirect_back_or_default(root_path)
    else
      flash[:error] = t(:login_failed)
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:success] = t(:logged_out)
    redirect_back_or_default(root_path)
  end
end
