require File.dirname(__FILE__) + '/../selenium_helper'

# class InvitedCommenterTest < Test::Unit::TestCase 
class InvitedCommenterTest < SeleniumTestCase 
  # attr_reader :browser
  # 
  # def setup
  #   @browser = Selenium::Client::Driver.new \
  #     :host => "localhost",
  #     :port => 4444,
  #     :browser => "*opera",
  #     :url => "http://dusk", 
  #     :timeout_in_second => 60
  #     
  #   browser.start_new_browser_session
  # end
  # 
  # def teardown
  #   browser.close_current_browser_session
  # end

  def test_commenter_can_log_in
    @@browser.open "/index.html#url_token=bde1ac52c249d8cc52690dfd5be56234"
    sleep 3
    assert @@browser.element?("css=#outspokes"), "Outspokes widget not present for a valid invited commenter"
  end

end