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

  def see_admin_panel?
    self.class.browser.visible?('outspokes_admin_panel')
  end

  def close_admin_panel
    assert see_admin_panel?, "Tried to close admin_panel when it wasn't open"
    self.class.browser.click 'outspokes_close_admin_panel'
    assert !see_admin_panel?
  end

  def open_comments_tab
    self.class.browser.click 'outspokes_comments_tab'
    # TODO: assert outspokes_comments_tab has class 'outspokes-current'
    # TODO: assert widget uncollapses
  end

  def see_comment?(comment)
    self.class.browser.visible?("comment_#{comment.id}")
  end

  def post_comment(content = "test comment")
    self.class.browser.type 'css=#outspokes_new_comment #outspokes_form_wrapper textarea[name=content]', content
    assert_difference "Comment.count" do
      self.class.browser.click 'css=#outspokes_form_buttons input[value=Post]'
      sleep 2
    end
    posted_comment = Comment.last
    assert see_comment?(posted_comment)
    posted_comment
  end

  def comment_present?(comment)
    self.class.browser.element?("comment_#{comment.id}")
  end

  def post_comment_reply(parent_comment, content = "test comment")
    assert comment_present?(parent_comment), "Missing parent comment to reply to"
    self.class.browser.click "css=#comment_#{parent_comment.id} button[class=outspokes_comment-reply]"#, :wait_for => :text, :text => "Reply to"
    self.class.browser.wait_for :text => /Reply to/i, :element => "css=#outspokes_form_header span"
    self.class.browser.type "css=#comment_#{parent_comment.id}_reply #outspokes_form_wrapper textarea[name=content]", content

    assert_difference "Comment.count" do
      self.class.browser.click 'css=#outspokes_form_buttons input[value=Reply]'
      sleep 2
    end
    reply_comment = Comment.last
    assert see_comment?(reply_comment)
  end
end
