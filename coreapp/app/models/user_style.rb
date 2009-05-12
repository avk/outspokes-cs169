class UserStyle < Feedback
  
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :changeset, :allow_blank => false
  
  def abstract?
    return false
  end
  
  
  def self.json_to_css(jsonStyle)
    
    jsonStyle.gsub!(/:eq/, "")
    jsonStyle.gsub!(/[>()]/, "")
    
    style = ActiveSupport::JSON.decode jsonStyle 
    
    cssStyle = ''
    
    style.each_pair {
       |k, v| 
       k.gsub(/[ ]/, "_")
       cssStyle += "\n.#{k.gsub(/[ ]/, "")} \{\n";
       v.each_pair {|k2, v2| 
         if v2.include?(' ') then
           cssStyle += "\t#{k2}: '#{v2}';\n"
          else
            cssStyle += "\t#{k2}: #{v2};\n" 
          end
          };
       cssStyle +=  "\}";
     }
    cssStyle
  end
  
end
