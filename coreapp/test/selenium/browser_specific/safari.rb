require File.dirname(__FILE__) + '/../../selenium_helper'

class SafariTest < SeleniumTestCase
  
  def test_go_to_safari
    @@browser.open "http://apple.com/safari"
  end
  
end
