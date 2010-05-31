class CourseInstance < ActiveRecord::Base
  belongs_to :course
  has_many :topics, :order => 'created_at DESC', :dependent => :destroy
  has_many :surveys, :order => 'closes_at ASC', :dependent => :destroy
  
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :course_id
  validates_format_of :path, :with => URL_FORMAT_MODEL
  validates_presence_of :name

  # Returns topics sorted by a criterion (date, commented, answered, thumbs_up, thumbs_down)
  # Options:
  # include_private: includes messages that are sent for staff only
  def sorted_topics(order, options = {})
    # Sorting order
    case order
      when 'commented'
        order_sql = 'commented_at DESC'
      when 'answered'
        order_sql = 'action_status DESC'
      when 'thumbs_up'
        order_sql = 'thumbs_up DESC'
      when 'thumbs_down'
        order_sql = 'thumbs_down ASC'
      else
        order_sql = nil
    end
    
    # Show private messages?
    condition_sql = "moderation_status != 'deleted'"
    condition_sql << " AND visibility = 'public'" unless options.has_key? :include_private

    topics.find_all_by_course_instance_id(self.id, :conditions => condition_sql, :order => order_sql)
  end


  # Sends a notication email to the users who want to be notified about activity in this course instance
  # Notifications are sent in a background process
  def notify_subscribers_later
    # Put the task to queue
    self.send_later(:notify_subscribers, self.id)
  end
  
  def notify_subscribers(instance_id)
    instance = CourseInstance.find(instance_id)
    
    # Find the list of users who want to be notified
    roles = Courserole.find_all_by_course_id(instance.course_id, :conditions => "role='teacher'")
    
    roles.each do |role|
      user = role.user

      # If user want's to be notified and hasn't been notified since last login, send notification
      if user.notify_by_email && (!user.last_notification_at || (user.last_login_at && user.last_notification_at < user.last_login_at))
        NotificationMailer.deliver_activity_notification(user, instance)
        user.touch(:last_notification_at)
      end
    end
  end

end
