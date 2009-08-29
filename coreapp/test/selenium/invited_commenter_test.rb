require File.dirname(__FILE__) + '/../selenium_helper'

class InvitedCommenterTest < SeleniumTestCase 
  @@default_url_options = { :host => CONFIG.selenium_demo_domain }  

  def test_commenter_can_log_in
    assert @@browser.element?('//html/body/div/div/div/a/img') # Outspokes logo
  end
  
end
