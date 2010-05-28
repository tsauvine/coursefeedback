class Message < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user, :primary_key => 'login', :foreign_key => 'user_login'
  
  def add_thumb_up
    Message.increment_counter(:thumbs_up, id)
    #User.increment_counter(:thumbs_up, user_id) if user_id
    self.thumbs_up += 1
  end
  
  def add_thumb_down
    Message.increment_counter(:thumbs_down, id)
    #User.increment_counter(:thumbs_down, user_id) if user_id
    self.thumbs_down += 1
  end
end
