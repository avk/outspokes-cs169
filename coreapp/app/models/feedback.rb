class Feedback < AbstractFeedback
  
  belongs_to :commenter

  validates_presence_of :commenter_id
  validates_associated :commenter
  
end
