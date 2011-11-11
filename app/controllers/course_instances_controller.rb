class CourseInstancesController < ApplicationController
  before_filter :load_course, :except => [:index, :new, :create, :update]

  def load_course
    if params[:id]
      @instance = CourseInstance.find(params[:id])
      @course = @instance.course if @instance
    elsif params[:course]
      @course = Course.find_by_code(params[:course])
      @instance = CourseInstance.find_by_path_and_course_id(params[:instance], @course.id) if @course
    end

    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to root_path
      return
    end

    unless @instance
      flash[:error] = t(:instance_not_found)
      redirect_to @course
      return
    end

    #@is_teacher = is_teacher?(current_user, @course)
    #@is_admin = is_admin?(current_user)
  end


  def index
    courses = Course.all
    @course_instances = Array.new

    courses.each do |course|
      instance = course.course_instances.first
      @course_instances << instance if instance
    end
  end


  def show

  end


  def new
    @course = Course.find(params[:course_id])
    #authorize_teacher_or_admin or return
    authorize! :create, CourseInstance

    @local_instance = CourseInstance.new(:course_id => @course.id)
  end

  # GET /courses/1/edit
  def edit
    #authorize_teacher_or_admin or return
    authorize! :update, @instance

    @local_instance = @instance
  end


  # POST /courses
  # POST /courses.xml
  def create
    @local_instance = CourseInstance.new(params[:course_instance])
    @course = @local_instance.course

    #authorize_teacher_or_admin or return
    authorize! :create, CourseInstance


    respond_to do |format|
      if @local_instance.save
        flash[:success] = t(:instance_created)
        format.html { redirect_to edit_course_path(@course) }
        format.xml  { render :xml => @local_instance, :status => :created, :location => @local_instance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @local_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    @instance = CourseInstance.find(params[:id])
    @course = @instance.course if @instance
    #authorize_teacher_or_admin or return
    authorize! :update, @instance

    @local_instance = CourseInstance.find(params[:id])

    respond_to do |format|
      if @local_instance.update_attributes(params[:course_instance])
        flash[:success] = t(:instance_updated)
        format.html { redirect_to edit_course_path(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @local_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    #authorize_teacher_or_admin or return
    authorize! :delete, @instance

    @instance.destroy

    respond_to do |format|
      format.html { redirect_to edit_course_path(@course) }
      format.xml  { head :ok }
    end
  end


end
