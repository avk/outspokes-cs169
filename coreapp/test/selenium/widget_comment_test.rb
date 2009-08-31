require File.dirname(__FILE__) + '/../selenium_helper'

class WidgetCommentTest < SeleniumTestCase 
  @@default_url_options = { :host => CONFIG.selenium_demo_domain }
  include WidgetHelper

  def test_admin_post_comment
    successful_admin_login
    open_comments_tab
    post_comment
  end

  def test_admin_reply_comment
    successful_admin_login
    open_comments_tab
    posted_comment = post_comment
    post_comment_reply(posted_comment)
  end
end
