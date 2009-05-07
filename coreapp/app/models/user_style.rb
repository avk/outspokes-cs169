class UserStyle < Feedback
  
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :changeset, :allow_blank => false
  
  def abstract?
    return false
  end
  
  def json_to_css(jsonStyle)
    style = JSON.parse jsonStyle
    
  end
  
end
