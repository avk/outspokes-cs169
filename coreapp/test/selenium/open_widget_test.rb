require File.dirname(__FILE__) + '/../selenium_helper'

class OpenWidgetTest < SeleniumTestCase
  include WidgetHelper
  
  # Admins
  
  def test_new_admin_session_should_see_login_form
    first_admin_visit
  end
  
  def test_new_admin_session_should_show_admin_widget_on_valid_login
    successful_admin_login
  end
  
  def test_new_admin_session_should_not_show_admin_widget_on_invalid_login
    first_admin_visit
    @@browser.type 'outspokes_email', 'cs169@berkeley.edu'
    @@browser.type 'outspokes_password', 'outspokes'
    @@browser.click 'outspokes_submit_login', :wait_for => :text, :text => 'Login invalid.'
    @@browser.wait_for :element => 'outspokes_login_form'
    sleep 2
    assert see_admin_login?
    assert !widget_present?
  end
  
  def test_returning_admin_should_see_widget_without_having_to_log_in
    successful_admin_login
    @@browser.open 'http://google.com'
    admin_visit
    assert !admin_login_present?
    assert widget_present?
  end
  
  # Commenters
  
  def test_new_commenter_session_should_see_widget_with_intro_bubble
    first_commenter_visit
  end
  
  def test_can_close_intro_bubble_by_clicking_on_a_close_intro_button
    first_commenter_visit
    @@browser.click('outspokes_close_intro')
    assert !see_intro_bubble?
  end
  
  def test_can_close_intro_bubble_by_clicking_on_the_widget
    first_commenter_visit
    @@browser.click('outspokes_topbar')
    assert !see_intro_bubble?
  end
  
  def test_returning_commenter_should_see_widget_without_intro_bubble
    commenter_visit
    @@browser.open 'http://google.com'
    commenter_visit
    assert widget_present?
    assert !intro_bubble_present?
  end
  
  # Everyone else
  
  def test_uninvited_users_should_not_see_widget
    clear_widget_cookies
    @@browser.open pages(:demo).url
    assert !widget_present?
  end
  
end
