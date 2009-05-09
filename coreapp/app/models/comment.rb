class Comment < Feedback
  validates_presence_of :content, :allow_blank => false
  validates_presence_of :target, :allow_blank => false
  
  def abstract?
    return false
  end
  
  def self.json_attribute_names
    super + %w(content target)
  end
  
end