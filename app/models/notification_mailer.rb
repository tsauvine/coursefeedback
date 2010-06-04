# NotificationMailer sends notification emails to users who want to be informed about new activity.
class NotificationMailer < ActionMailer::Base

  # Sends a notification email about new activity on a course instance.
  # Params:
  # user::     User object
  # instance:: CourseInstance object
  def activity_notification(user, instance)
    # Set locale
    I18n.locale = user.locale
    
    course = instance.course
    
    @subject = I18n.t(:notification_subject, :course => course.name)
    @sent_on = Time.now
    @from = NOTIFICATIONS_SENDER_EMAIL
    @recipients = user.email
    @template = "#{I18n.locale}_activity_notification"

    @body[:instance] = instance
  end

end
