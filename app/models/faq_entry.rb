class FaqEntry < ActiveRecord::Base
  belongs_to :course
  
  validates_presence_of :caption
  
end
