require 'ipaddr'

class TopicsController < ApplicationController

  def load_course
    @course = Course.find_by_code(params[:course])
    
    unless @course
      flash[:error] = t(:course_not_found)
      redirect_to courses_url
      return
    end
    
    @instance = CourseInstance.find_by_path_and_course_id(params[:instance], @course.id) if @course

    unless @instance
      flash[:error] = t(:instance_not_found)
      redirect_to @course
      return
    end

    @is_teacher = is_teacher?(current_user, @course)
    @is_admin = is_admin?(current_user)
    
    return true
  end
  
  
  # GET /topics
  # GET /topics.xml
  def index
    load_course or return
    #authorize_level @course.feedback_read_permission or return

    # Allow sending?
    @allow_send = @instance.active && allow_send?
    @allow_read = allow_read?
    @allow_headlines = allow_read_headlines?

    if @is_teacher
      @topics = @instance.sorted_topics(params[:sort], :include_private => true)
      render :action => 'index_staff'
    else
      @topics = @instance.sorted_topics(params[:sort])
      render :action => 'index'
    end
    
    # @queue_length = Topic.count(:conditions => ["course_instance_id=? AND moderation_status='pending'", @instance.id])
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])
    @instance = @topic.course_instance
    @course = @instance.course
    
    @allow_send = @instance.active && allow_send?
    @allow_vote = @allow_send && !is_teacher?(current_user, @course)
    
    # Check reading privileges
    authorize_level @course.feedback_read_permission or return
    
    # Censorship
    return access_denied unless @topic.moderation_status == 'published' || is_teacher?(current_user, @course)
    
    @is_teacher = is_teacher?(current_user, @course)
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    load_course or return
    authorize_level @course.feedback_write_permission or return
    
    # If instance is closed
    unless @instance.active
      flash[:error] = t(:instance_closed)
      redirect_to instace_path(@course.code, @instance.path)
      return
    end
  
    @topic = Topic.new(:course_instance_id => @instance.id, :nick => 'Anonymous')
    #@topic.nick = logged_in? ? current_user.name : 'Anonymous'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
    @instance = @topic.course_instance
    @course = @instance.course
    
    authorize_teacher or return
  end

  # POST /topics
  # POST /topics.xml
  def create
    # Read form
    @topic = Topic.new(params[:topic])
    @instance = @topic.course_instance
    @course = @instance.course
    @is_teacher = is_teacher?(current_user, @course)
    
    # Check writing permissions
    authorize_level @course.feedback_write_permission or return
    
    # If instance is closed
    unless @instance.active
      flash[:error] = t(:instance_closed)
      redirect_to instace_path(@course.code, @instance.path)
      return
    end
    
    
    @topic.moderation_status = (@course.moderate && !@is_teacher && @topic.visibility == 'public') ? 'pending' : 'published'
    @topic.action_status = 'unanswered'
    @topic.nick = 'Anonymous' if @topic.nick.blank?
    
    # User
    if logged_in? && !@topic.anonymous
      #@topic.anonymous = (@topic.nick != current_user.name)
      @topic.user = current_user
      @topic.nick = current_user.name
    end
    
    # Save topic
    unless @topic.save
      flash[:error] = 'Failed to send feedback'
      render :action => "new"
      return
    end
    
    if @topic.moderation_status == 'pending'
      flash[:success] = t(:added_to_queue) 
    else
      flash[:success] = t(:topic_opened)
    end
    
    # Email notification
    @instance.notify_subscribers_later
    
    redirect_to topic_index_path(@course.code, @instance.path)
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])
    @instance = @topic.course_instance
    @course = @instance.course
    authorize_teacher or return

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:success] = t(:topic_updated)
        format.html { redirect_to(@topic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    authorize_admin or return

    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(topics_url) }
      format.xml  { head :ok }
    end
  end
  
  def vote
    @topic = Topic.find(params[:id])
    @instance = @topic.course_instance
    @course = @instance.course
    
    authorize_level @course.feedback_write_permission or return
    
    if params[:amount].to_i > 0
      @topic.add_thumb_up
    else
      @topic.add_thumb_down
    end
    
    render :partial => 'messages/thumbs', :locals => {:message => @topic}
  end
  
  def moderate
    @topic = Topic.find(params[:id])
    @instance = @topic.course_instance
    @course = @instance.course
    
    authorize_teacher or return
  
    case params[:status]
      when 'accept':
        new_status = 'published'
      when 'reject':
        new_status = 'censored'
      when 'delete':
        new_status = 'deleted'
      else
        render :partial => 'moderation'
        return
    end
    
    @topic.moderation_status = new_status
    @topic.save
    
    # Update messages
    #Message.update_all("moderation_status='#{new_status}'", "topic_id=#{@topic.id}")
    
    if request.xhr?
      # TODO
      render :text => new_status
    else
      flash[:success] = t("moderated_#{new_status}")
      redirect_to @topic
    end
  end


  protected
    def allow_send?
      authorized_level?(current_user, @course, @course.feedback_write_permission)
    end

    def allow_read?
      authorized_level?(current_user, @course, @course.feedback_read_permission)
    end
    
    def allow_read_headlines?
      authorized_level?(current_user, @course, @course.headlines_read_permission)
    end

end
