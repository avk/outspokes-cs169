class PrivateFeedback < Feedback
  
  belongs_to :commenter

  validates_presence_of :commenter_id
  validates_associated :commenter
  
  def abstract?
    return false
  end
  
  
end
