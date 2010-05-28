class FaqController < ApplicationController
  before_filter :load_course, :except => [:create]
  before_filter :authorize_teacher, :except => [:index, :create]
  
  def load_course
    if params[:id]
      @entry = FaqEntry.find(params[:id])
      @course = @entry.course
    else
      @course = Course.find_by_code(params[:course_code])
    end
    
    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to courses_url
      return
    end
    
    @instance = CourseInstance.find_by_path_and_course_id(params[:instance_path], @course.id) if @course
    unless @instance
      flash[:error] = t(:instance_not_found)
      redirect_to @course
      return
    end

    @is_teacher = is_teacher?(current_user, @course)
    @is_admin = is_admin?(current_user)
    @allow_edit = is_teacher?(current_user, @course)
    
    return true
  end
 
 
  def index
    @entries = @course.faq_entries
  end
  
  
  def new
    authorize_teacher or return
    
    @entry = FaqEntry.new(:course_id => @course.id)
    
    if params[:message_id]
      message = Message.find(params[:message_id])
      @topic = message.topic
      @entry.caption = @topic.caption
      
      # If adding an answer to the faq, load the thread opening as the question
      if message.staff
        @entry.question = @topic.text
        @entry.answer = message.text
      else
        @entry.question = message.text
        answer = @topic.find_answer
        @entry.answer = answer.text if answer
      end
    elsif params[:topic_id]
      @topic = Topic.find(params[:topic_id])
      answer = @topic.find_answer

      @entry.caption = @topic.caption
      @entry.question = @topic.text
      @entry.answer = answer.text if answer
    end
  end
  
  def edit
    authorize_teacher or return
  end


  def create
    @entry = FaqEntry.new(params[:faq_entry])
    @course = @entry.course
    @instance = CourseInstance.find_by_path_and_course_id(params[:instance_path], @course.id) if @course
    
    authorize_teacher or return
    
    @entry.position = @course.faq_entries.size + 1
    
    respond_to do |format|
      if @entry.save
        flash[:success] = t(:faq_entry_created)
        format.html { redirect_to faq_path(@course.code, @instance.path) }
        format.xml  { render :xml => @entry, :status => :created, :location => @entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    authorize_teacher or return
  
    respond_to do |format|
      if @entry.update_attributes(params[:faq_entry])
        flash[:success] =  t(:updated)
        format.html { redirect_to faq_path(@course.code, @instance.path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @faq.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    authorize_teacher or return
  
    @entry.destroy

    # Update page
    if request.xhr?
      render :update do |page|
        page.remove "entry#{@entry.id}"
      end
    else
      redirect_to faq_path(@course.code, @instance.path)
    end
  end
  
  
end
