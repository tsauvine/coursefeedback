class MessagesController < ApplicationController

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new
    @message.topic = Topic.find(params[:topic_id])
    
    @message.nick = logged_in? ? current_user.name : 'Anonymous'

    respond_to do |format|
      format.js { render 'new' }
    end
  end

  # GET /messages/1/edit
  def edit
    authorize_admin or return
  
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.xml
  def create
    @message = Message.new(params[:message])
    @topic = @message.topic
    @instance = @topic.course_instance
    @course = @instance.course
    @is_teacher = @course.has_teacher?(current_user)
  
    # Authorization
    authorize! :write_feedback, @course

    unless @instance.active
      flash[:error] = t(:instance_closed)
      redirect_to @topic
      return
    end
  

    # Sender
    @message.nick = 'Anonymous' if @topic.nick.blank?
    
    if logged_in?
      @message.anonymous = (@message.nick != current_user.name)
      @message.user = current_user unless @message.anonymous

      if @is_teacher && !@message.anonymous
        @message.staff = true
        @topic.action_status = 'answered'
      end
    end
    
    @message.moderation_status = (@course.moderate && !@is_teacher) ? 'pending' : 'published'
    
    # Update topic
    @topic.commented_at = Time.now
    @topic.save
    
    # Email notification
    @instance.notify_subscribers_later
    
    # Save message
    if @message.save
      flash[:success] = t(:added_to_queue) if @message.moderation_status == 'pending'
      redirect_to topic_url(@topic, :anchor => 'messageEditor')
    else
      flash[:error] = 'Failed to save comment'
      redirect_to @topic
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
  def update
    authorize_admin or return

    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        flash[:success] = 'Message was successfully updated.'
        format.html { redirect_to(@message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    authorize_admin or return
  
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url) }
      format.xml  { head :ok }
    end
  end
  
  def moderate
    @message = Message.find(params[:id])
    @instance = @message.topic.course_instance
    @course = @instance.course
    @is_teacher = @course.has_teacher?(current_user)
    
    authorize_teacher or return
  
    case params[:status]
      when 'accept':
        @message.moderation_status = 'published'
      when 'reject':
        @message.moderation_status = 'censored'
      when 'delete':
        @message.moderation_status = 'deleted'
      else
        render :partial => 'moderation', :locals => {:message => @message}
        return
    end
    
    @message.save
    logger.info "Saving message"
    
    # Update page
    if request.xhr?
      render :update do |page|
        if @message.moderation_status == 'deleted' 
          page.remove "message#{@message.id}"
        else
          page.replace "message#{@message.id}", :partial => 'message', :object => @message
        end
      end
    else
      render :action => 'show'
    end
  end
  
  def vote
    @message = Message.find(params[:id])
    @course = @message.topic.course_instance.course
    
    # Authorization
    authorize! :write_feedback, @course
    return access_denied unless @message.moderation_status == 'published'
    
    if params[:amount].to_i > 0
      @message.add_thumb_up
    else
      @message.add_thumb_down
    end
    
    respond_to do |format|
      #format.html { render :partial => 'thumbs', :locals => {:message => @message} }
      format.js { render :thumbs, :locals => {:message => @message} }
    end
    
    
  end
  
end
