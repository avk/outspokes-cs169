require File.dirname(__FILE__) + '/../selenium_helper'

class RegistrationTest < SeleniumTestCase
  @@default_url_options = { :host => CONFIG.domain }

  def test_register_new_account
    register_account
  end
  
end
