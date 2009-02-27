class Feedback < ActiveRecord::Base
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :commenter_id
  validates_associated :commenter
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :content, :allow_blank => false
end
