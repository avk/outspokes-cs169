require File.dirname(__FILE__) + '/../selenium_helper'

class InvitedCommenterTest < SeleniumTestCase 
  
  def test_commenter_can_log_in
    assert @@browser.element?('//html/body/div/div/div/a/img') # Outspokes logo
  end
  
end
