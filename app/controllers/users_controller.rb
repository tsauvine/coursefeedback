class UsersController < ApplicationController

  # render new.rhtml
  def new
    authorize! :create, User

    @user = User.new
  end

  def create
    authorize! :create, User

    # cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with request forgery protection.
    # uncomment at your own risk
    # reset_session

    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      #self.current_user = @user
      #redirect_back_or_default(root_path)
      flash[:success] = "User successfully created"
    end

    render :action => 'new'
  end

  def edit
    @user = User.find(params[:id])
    authorize! :update, @user
    #return access_denied unless @user == current_user || is_admin?(current_user)

    #@is_teacher = is_admin?(current_user) || is_teacher?(current_user, :any)
  end


  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    #return access_denied unless @user == current_user || is_admin?(current_user)

    #@is_teacher = is_admin?(current_user) || is_teacher?(current_user, :any)

    # FIXME: Only allow teachers to change their name
    #unless @is_teacher
    #  params[:user].delete(:name)
    #end

    if @user.update_attributes(params[:user])
      flash[:success] = t(:user_updated)
    else
      flash[:error] = 'Failed to update user.'
    end

    render :action => 'edit'
  end
end
