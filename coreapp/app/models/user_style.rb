class UserStyle < Feedback
  
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :changeset, :allow_blank => false
  
  def abstract?
    return false
  end
  
  def json_to_css(jsonStyle)
    
    jsonStyle.gsub!(/:eq/, "")
    jsonStyle.gsub!(/[>() ]/, "")
    
    cssStyle = JSON.parse jsonStyle #hash object with keys are classes
    
    #cssStyle.each_key {|key| key.gsub!(/[>() ]/, "") } frozen string error
    
  end
  
end
