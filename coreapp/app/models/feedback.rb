class Feedback < ActiveRecord::Base
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :commenter
  validates_presence_of :page
  
  validates_presence_of :content, :allow_blank => false
end
