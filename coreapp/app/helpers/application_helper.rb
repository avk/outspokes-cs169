# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def sanitize(value, newlines)
    value = ERB::Util.html_escape(value)
    if newlines
      replace_val = "<br />"
    else
      replace_val = " "
    end
    value.gsub!(/\r\n/, replace_val)
    value.gsub!(/[\r\n]/, replace_val)
    return value
  end
  
  def url_link_text(url)
    link_text = URI.parse(url).path
    return link_text.empty? ? "/" : link_text
  end
  
end
