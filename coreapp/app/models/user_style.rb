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
    
    style = JSON.parse jsonStyle
    
    cssStyle = ''
    
    style.each_pair {
       |k, v| cssStyle += "\n.#{k} \{\n";
       v.each_pair {|k2, v2| cssStyle += "\t#{k2}: #{v2};\n" };
       cssStyle +=  "\}";
     }
    
  end
  
end
