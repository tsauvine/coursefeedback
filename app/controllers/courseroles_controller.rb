class CourserolesController < ApplicationController
  before_filter :load_course
  
  def load_course
    @course = Course.find(params[:course_id])

    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to courses_path
      return false
    end

    @is_teacher = @course.has_teacher?(current_user) || is_admin?(current_user)
    @is_admin = is_admin?(current_user)
  end
  
  
  def new
    authorize! :manage, @course
    
    @courserole = Courserole.new
  
    render :action => 'new', :layout => false
  end
  
  def create
    authorize! :manage, @course
    
    @courserole = Courserole.new(params[:courserole])
    @courserole.course = @course
    @courserole.role = 'teacher'

    @courserole.save
    
    render :partial => 'index'
  end


  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    authorize! :manage, @course
    
    @courserole = Courserole.find(params[:id])
    @courserole.destroy

    render :partial => 'index'
  end
end
