require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase

  test 'feedbacks cannot be created' do
    assert_raises RuntimeError do
      f = Feedback.new
    end
  end

  test "should be able to return feedback across an entire site" do
    url = "http://outspokes.com"
    account = commenters(:quentin)
    commenter = commenters(:aaron)
    
    site = create_site(:account => account, :url => url)
    another_page = create_page(:site => site, :url => url + '/about')
    create_invite(:commenter => commenter, :page => site.home_page)
    
    site.reload # reload the site because it's not aware of another_page yet
    
    f = []
    f << create_comment(:page => site.home_page, :commenter => account)
    f << create_comment(:page => another_page, :commenter => commenter)
    f << create_user_style(:page => another_page, :commenter => account)
    
    expected = f
    got = Feedback.for_site(site)
    assert expected == got, "all feedback: \n#{expected.inspect}\nbut got: \n#{got.inspect}"
  end
  
  test "should be able to tell the latest feedback" do
    latest = nil
    sleep 0.5 # because somehow what's below is non-deterministic
    assert_difference "Feedback.count", 1 do
      latest = create_comment
    end
    
    expected = latest
    got = Feedback.latest.first
    assert expected == got, "latest feedback was #{latest.inspect} but got #{got.inspect}"
  end
  
end

