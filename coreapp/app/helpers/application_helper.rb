# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def same_domain?(url1, url2)
    URI.parse(url1).host() == URI.parse(url2).host() && URI.parse(url1).port() == URI.parse(url2).port()
  end

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
end
