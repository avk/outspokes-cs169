class UserStyle < Feedback
  
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :changeset, :allow_blank => false
  
  def abstract?
    return false
  end
  
  
  def self.json_to_css(jsonStyle)
    css = ''
    
    begin
      style = ActiveSupport::JSON.decode jsonStyle
      style.each_pair do |selector, properties|
        # .classname {
        css += "\n." + self.to_css_class(selector) + " \{\n"
        
        properties.each_pair do |property, value|
          #   property: value;
          css += "\t#{property}: "
          if property == "font-family"
            value.split(",").each do |font|
              css += "'#{font}'"
            end
          else
            css += value
          end
          css += " !important;\n"
        end
        
        css += "\}\n"
        # }
      end
    rescue ActiveSupport::JSON::ParseError => e
      logger.error "could not parse UserStyle: #{e}"
    end
    
    css
  end
  
  def self.to_css_class(str)
    # http://www.w3.org/TR/CSS21/syndata.html#characters
    str.gsub /[^a-zA-Z0-9\-\_]/, ''
  end
  
  
end
