# CourseInstance is the incarnation of a course on a specific semester. For example, course 'Programming 101' could have instances 'Fall 2010' and 'Spring 2010'.
#
# Attributes:
#
# name::     name of the instance, e.g. "Fall 2010"
# path::     used in URLs, e.g. "f2010"
# position:: instances are ordered by position [1,n]
# active::   if false, new topics cannot be opened

class CourseInstance < ActiveRecord::Base
  belongs_to :course
  has_many :topics, :order => 'created_at DESC', :dependent => :destroy
  has_many :questionnaires, :dependent => :destroy # :order => 'closes_at ASC'
  
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :course_id
  validates_format_of :path, :with => URL_FORMAT_MODEL
  validates_presence_of :name

  attr_accessible :course, :name, :path, :position, :active
  
  # Returns topics sorted by an attribute.
  # Parameters: 
  # order:: one of: 'date', 'commented', 'answered', 'thumbs_up', 'thumbs_down'
  # options:: hash
  #
  # Possible options
  # include_private:: includes messages that are sent for staff only
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

    # FIXME
    topics.find_all_by_course_instance_id(self.id, :conditions => condition_sql, :order => order_sql)
  end


  # Sends a notication email to the users who want to be notified about activity on this course instance.
  # Notifications are sent in a background process (delayed_job).
  def notify_subscribers_later
    # Put the task to queue
    # FIXME
    #self.send_later(:notify_subscribers, self.id)
  end
  
  # used by delayed_job
  def notify_subscribers(instance_id)
    # FIXME
    instance = CourseInstance.find(instance_id)
    
    # Find the list of users who want to be notified
    # FIXME
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
