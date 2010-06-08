# Topic class represents a thread of messages. 
#
# Attributes:
#
# course_instance_id:: 
# user_login::         username of the sender
# nick::               pseudonym of the sender
# anonymous::          if true, sender's identity must not be revealed even if it is recorded
# visibility::         'public' if sender wants the topic to to be discussed publicly, 'staff' if the feedback meant for staff only
# caption::            heading of the topic
# text::               content (feedback)
# moderation_status::  'pending', 'published', 'censored' or 'deleted'
# action_status::      null or 'answered' if course staff has participated the discussion
# thumbs_up::          thumb counter
# thumbs_down::        thumb counter
# commented_at::       timestamp of the latest message
# created_at::         timestamp
# updated_at::         timestamp

class Topic < ActiveRecord::Base
  belongs_to :course_instance
  belongs_to :user, :primary_key => 'login', :foreign_key => 'user_login'
  
  has_many :messages, :order => 'created_at ASC', :conditions => "moderation_status != 'deleted'", :dependent => :destroy

  def caption
    caption = read_attribute(:caption)
    
    if caption.blank?
      # Show the beginning of the feedback if no caption is given
      read_attribute(:text)[0,30] + '...'
    else
      caption
    end
  end

  # Returns the first answer from staff or nil if an answer is not found
  def find_answer
    Message.find_by_topic_id(id, :conditions => 'staff=true')
  end

  def add_thumb_up
    Topic.increment_counter(:thumbs_up, id)
    #User.increment_counter(:thumbs_up, user_id) if user_id
    self.thumbs_up += 1
  end
  
  def add_thumb_down
    Topic.increment_counter(:thumbs_down, id)
    #User.increment_counter(:thumbs_down, user_id) if user_id
    self.thumbs_down += 1
  end
  
end
