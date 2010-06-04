# Message represents a comment to a topic.

# Attributes:
# user_login::        login name of sender
# nick::              pseudonym of the sender
# anonymous::         true indicates that the username must not be published even if it's recorded
# staff::             true indicates that this comment is from course staff
# text::              content of the comment
# moderation_status:: one of: 'pending', 'published', 'censored', 'deleted'
# thumbs_up::         thumb counter
# thumbs_down::       thumb counter
# created_at::        messages are ordered by created_at

class Message < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user, :primary_key => 'login', :foreign_key => 'user_login'
  
  # Increases the thums_up counter by one.
  def add_thumb_up
    Message.increment_counter(:thumbs_up, id)
    #User.increment_counter(:thumbs_up, user_id) if user_id
    self.thumbs_up += 1
  end
  
  # Increases the thums_down counter by one.
  def add_thumb_down
    Message.increment_counter(:thumbs_down, id)
    #User.increment_counter(:thumbs_down, user_id) if user_id
    self.thumbs_down += 1
  end
end
