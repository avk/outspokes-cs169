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
    filename = "stylefile.css"
    
    cssStyle = JSON.parse jsonStyle #hash object with keys are classes
    
    f = File.new(filename, "w")
    
    cssStyle.each_pair {
      |k, v| f.write(".#{k} \{");
      v.each_pair {|k2, v2| f.write("\t#{k2}: #{v2};\n") };
      f.write("\}");
    }
    
    
  end
  
end
