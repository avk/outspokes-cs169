class Comment < Feedback
  validates_presence_of :content, :allow_blank => false
  validates_presence_of :target, :allow_blank => false
  
  def abstract?
    return false
  end
  
end