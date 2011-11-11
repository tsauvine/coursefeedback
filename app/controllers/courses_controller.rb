class CoursesController < ApplicationController
  before_filter :load_course, :except => [:index, :new, :create]


  def load_course
    if params[:id]
      @course = Course.find(params[:id])
    elsif params[:course_code]
      @course = Course.find_by_code(params[:course_code])
    end

    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to courses_path
      return
    end

    #@is_teacher = is_teacher?(current_user, @course) || is_admin?(current_user)
    #@is_admin = is_admin?(current_user)
  end


  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all(:order => 'code')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    #authorize :admin or return
    authorize! :create, Course

    @local_course = Course.new
  end

  # GET /courses/1/edit
  def edit
    #authorize :teacher, :admin or return
    authorize! :update, @course

    @local_course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    #authorize :admin or return
    authorize! :create, Course

    @local_course = Course.new(params[:course])

    respond_to do |format|
      if @local_course.save
        flash[:success] = t(:course_created)
        format.html { redirect_to edit_course_path(@local_course) }
        format.xml  { render :xml => @local_course, :status => :created, :location => @local_course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @local_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    #authorize :teacher, :admin or return
    authorize! :update, @course

    @local_course = Course.find(params[:id])

    respond_to do |format|
      if @local_course.update_attributes(params[:course])
        flash[:success] = t(:course_updated)
        format.html { redirect_to(edit_course_path(@local_course)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @local_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])

    #authorize :admin or return
    authorize! :delete, @course

    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
end
