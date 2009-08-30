require File.dirname(__FILE__) + '/../../selenium_helper'

class FirefoxTest < SeleniumTestCase
  
  def test_go_to_firefox
    @@browser.open "http://getfirefox.com/"
  end
  
end
