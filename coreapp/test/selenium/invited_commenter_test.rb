require File.dirname(__FILE__) + '/../selenium_helper'

class InvitedCommenterTest < SeleniumTestCase 
  def test_commenter_can_log_in
    @@browser.open "/index.html#url_token=bde1ac52c249d8cc52690dfd5be56234"
    sleep 3
    assert @@browser.element?("css=#outspokes"), "Outspokes widget not present for a valid invited commenter"
  end
end
