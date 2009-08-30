require File.dirname(__FILE__) + '/../selenium_helper'

class SanityTest < SeleniumTestCase
  # run through an entire use of our app
  def test_the_sanity_of_outspokes
    credentials = {
      :email    => 'jerry+sanity@localhost.com',
      :password => 'asdfasdf'
    }
    register_account(credentials)
    logout_account
    login_account(credentials)
  end
end
