# FaqEntry contains an FAQ question and an answer.
#
# Attributes:
# caption::      Caption of the entry
# question::     Question text (optional)
# answer::       Answer text (optional)
# position::     Entries are ordered by position
# thumbs_up::    reserved for future use
# thumbs_down::  reserved for future use

class FaqEntry < ActiveRecord::Base
  belongs_to :course
  
  validates_presence_of :caption

  attr_accessible :course_id, :caption, :question, :answer
end
