class Comment < Feedback
  
  belongs_to :page
  belongs_to :commenter
  
  validates_presence_of :content, :allow_blank => false
  validates_presence_of :target, :allow_blank => false
  
  def abstract?
    return false
  end
  
  def self.json_attribute_names
    super + %w(content target isPrivate)
  end
  
  def search_score(terms) 
    score = 0
    terms.map{|term| if(self.content.downcase.include? term.downcase) then score += term.length; end}
    score
  end
  
end
