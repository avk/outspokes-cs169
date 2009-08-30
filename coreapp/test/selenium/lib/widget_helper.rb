module WidgetHelper
  def clear_widget_cookies
    self.class.browser.delete_cookie('outspokes_widget_state')
    self.class.browser.delete_cookie('fb_hash_url_token')
    self.class.browser.delete_cookie('fb_hash_admin_validation_token')
  end
  
  def admin_visit
    self.class.browser.open pages(:demo).admin_url
  end
  
  def first_admin_visit
    clear_widget_cookies
    admin_visit
    assert see_admin_login?
    assert !widget_present?
  end
  
  def commenter_visit
    self.class.browser.open pages(:demo).commenter_url(commenters(:demo_commenter))
  end
  
  def first_commenter_visit
    clear_widget_cookies
    commenter_visit
    assert widget_present?
    assert see_intro_bubble?
  end
  
  def see_admin_login?
    self.class.browser.visible?('outspokes_login_form')
  end
  
  def admin_login_present?
    self.class.browser.element?('outspokes_login_form')
  end
  
  def widget_present?
    self.class.browser.element?('outspokes')
  end
  
  def see_intro_bubble?
    self.class.browser.visible?('outspokes_bubble')
  end
  
  def intro_bubble_present?
    self.class.browser.element?('outspokes_bubble')
  end
  
  def successful_admin_login
    first_admin_visit
    self.class.browser.type 'outspokes_email', commenters(:demo_admin).email
    self.class.browser.type 'outspokes_password', 'monkey' # depends on demo_admin fixture
    self.class.browser.click 'outspokes_submit_login', :wait_for => 'outspokes'
    sleep 2
    assert widget_present?
    assert self.class.browser.element?('outspokes_open_admin_panel')
  end  
end
