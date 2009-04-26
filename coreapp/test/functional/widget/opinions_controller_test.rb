require File.dirname(__FILE__) + '/../../test_helper'


class Widget::OpinionsControllerTest < ActionController::TestCase
  
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  test "should not allow opinions for an invalid URL token" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    feedback = feedbacks(:two)
    assert invite.commenter_id != feedback.commenter_id
    
    assert_no_difference "Opinion.count" do
      post :opinion, :url_token => "LOL!!!!!", :current_page => page.url, 
           :feedback_id => feedback.id, :opinion => 'agree', :callback => callback, :format => "html"
    end
    
    validate_windowname :authorized => false
  end
  
  test "should not allow opinions given an invalid page" do
    invite = invites(:one)
    callback = 'jsfeed'
    feedback = feedbacks(:two)
    assert invite.commenter_id != feedback.commenter_id
    
    assert_no_difference "Opinion.count" do
      post :opinion, :url_token => invite.url_token, :current_page => 'bullshit', 
           :feedback_id => feedback.id, :opinion => 'agree', :callback => callback, :format => "html"
    end
    
    validate_post_fail
  end
  
  test "should not allow opinions given a callback that's not a valid JavaScript function name" do
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters
    
    # Also:
    # - Cannot be a JavaScript keyword
    
    invite = invites(:one)
    feedback = feedbacks(:two)
    assert invite.commenter_id != feedback.commenter_id
    
    illegal_chars = %w(123 no:colons hash# apo'strope per%cent mult*iply add+ition fake<html>)
    # keywords = %w(window open location string document with case)
    spaces = ['no spaces']
    
    illegal_callbacks = illegal_chars + js_keywords + spaces
    illegal_callbacks.each do |callback|
      assert_no_difference "Opinion.count" do
        post :opinion, :url_token => invite.url_token, :current_page => invite.page.url, 
             :feedback_id => feedback.id, :opinion => 'agree', :callback => callback, :format => "html"
        assert @response.body == '{}'
      end
    end
  end
  
  test "should not allow opinions given invalid opinion values" do
    invite = invites(:one)
    feedback = feedbacks(:two)
    callback = 'jsfeed'
    assert invite.commenter_id != feedback.commenter_id
    
    invalid = ['', nil, 9808, 'asdfasdfasd']
    
    invalid.each do |inv|
      assert_no_difference "Opinion.count" do
        post :opinion, :url_token => invite.url_token, :current_page => invite.page.url, 
             :feedback_id => feedback.id, :opinion => '', :callback => callback, :format => "html"
      end
      validate_post_fail
    end
  end
  
  test "should not allow opinions with an invalid feedback id" do
    invite = invites(:one)
    callback = 'jsfeed'
    bad_feedback_ids = ['', nil, 'asfdasfdas', 0, -123423423]
    
    bad_feedback_ids.each do |f_id|
      assert_no_difference "Opinion.count" do
        post :opinion, :url_token => invite.url_token, :current_page => invite.page.url, 
             :feedback_id => f_id, :opinion => 'agreed', :callback => callback, :format => "html"
      end
      validate_post_fail
    end
  end
  
  test "should allow people to agree with a feedback" do
    invite = invites(:two)
    callback = 'jsfeed'
    feedback = feedbacks(:one)
    assert invite.commenter_id != feedback.commenter_id
    opinion = 'agree'
    
    assert_difference "Opinion.count" do
      post :opinion, :url_token => invite.url_token, :current_page => invite.page.url, 
           :feedback_id => feedback.id, :opinion => opinion, :callback => callback, :format => "html"
    end
    
    validate_windowname :authorized => true, :feedback_id => feedback.id.to_s, :opinion => opinion
  end

  test "should allow people to disagree with a feedback" do
    invite = invites(:two)
    callback = 'jsfeed'
    feedback = feedbacks(:one)
    assert invite.commenter_id != feedback.commenter_id
    opinion = 'disagree'
    
    assert_difference "Opinion.count" do
      post :opinion, :url_token => invite.url_token, :current_page => invite.page.url, 
           :feedback_id => feedback.id, :opinion => opinion, :callback => callback, :format => "html"
    end
    
    validate_windowname :authorized => true, :feedback_id => feedback.id.to_s, :opinion => opinion
  end
end
