require 'test_helper'

class Widget::FeedbacksControllerTest < ActionController::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  test "should not list feedback for an invalid URL token" do
    invite = invites(:one)
    callback = "rofflecopter"
    feedback = []
    
    get :feedback_for_page, :url_token => 'bullshit', :current_page => invite.page.url, :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback, :url => 'default'
  end
  
  test "should not list feedback for an invalid page" do
    invite = invites(:one)
    callback = "rofflecopter"
    feedback = []
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => 'bullshit', :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback, :url => 'default'
  end

  test "should not list feedback for a page a commenter hasn't been invited to" do
    invite = invites(:one)
    callback = "rofflecopter"
    feedback = []
    uninvited_page_url = Page.find(:first, :conditions => [ "id != ?", invite.page.id ]).url
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => uninvited_page_url, :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback, :url => 'default'
  end
  
  test "should render an empty list of feedback for a valid page that doesn't exist" do
    invite = invites(:one)
    callback = 'rover'
    feedback = []
    page_url = "http://" + URI.parse(invites(:one).page.url).host + "/nowayinhellshouldthisbeinourfixtures.xhtml"
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => page_url, :callback => callback
    
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should not list feedback for a page given a callback that's not a valid JavaScript function name" do
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters
    
    # Also:
    # - Cannot be a JavaScript keyword
    
    invite = invites(:one)
    illegal_chars = %w(123 no:colons hash# apo'strope per%cent mult*iply add+ition fake<html>)
    spaces = ['no spaces']
    
    illegal_callbacks = illegal_chars + js_keywords + spaces
    illegal_callbacks.each do |callback|
      get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback, :format => "js"
      assert @response.body == '{}'
    end
  end

  test "should list feedback for page" do
    invite = invites(:one)
    callback = 'jsfeed'
    feedback = invite.page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    
    assert invite.page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback
    
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should add new feedback for page" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html"
    end
    
    feedback = page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should create new page when adding feedback for new url" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    new_url = page.url + "/ASDFWUTLOL.asp.html"
    
    assert_difference "Page.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => new_url, :callback => callback, :content => content, :target => "html"
    end
    new_page = Page.find_by_url new_url
    assert ! new_page.nil?, "page was created successfully"
    assert new_page.feedbacks.count == 1, "feedback was attached to new page"
    
    feedback = new_page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should not add new feedback for page for an invalid URL token" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "Comment.count" do
      post :new_feedback_for_page, :url_token => "LOL!!!!!", :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html"
    end
    
    validate_json :callback => callback, :authorized => false
  end
  
  test "should not add new feedback to an invalid page" do
    invite = invites(:one)
    callback = 'jsfeed'
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "Comment.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "html", 
          :current_page => "bullshit", :callback => callback, :content => content, :target => "html"
    end

    validate_post_fail
  end
  
  test "should not add new feedback for a page given a callback that's not a valid JavaScript function name" do
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters
    
    # Also:
    # - Cannot be a JavaScript keyword
    
    invite = invites(:one)
    illegal_chars = %w(123 no:colons hash# apo'strope per%cent mult*iply add+ition fake<html>)
    # keywords = %w(window open location string document with case)
    spaces = ['no spaces']
    
    illegal_callbacks = illegal_chars + js_keywords + spaces
    illegal_callbacks.each do |callback|
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
           :current_page => invite.page.url, :callback => callback, :content => 'doesn\'t matter', :target => "html"
      assert @response.body == '{}'
    end
  end
  
  test "should not add new feedback that has no content" do
    invite = invites(:one)
    page = invite.page
    callback = 'jsfeed'
    
    assert_no_difference "Comment.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "html", 
          :current_page => page.url, :callback => callback, :content => '', :target => "html"
    end
    
    validate_post_fail
  end

  test "should not add new feedback that has no target" do
    invite = invites(:one)
    page = invite.page
    callback = 'jsfeed'
    
    assert_no_difference "Comment.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "html",
          :current_page => page.url, :callback => callback, :content => 'anything at all', :target => ''
    end
    
    validate_post_fail 
  end
  
  test "should add feedback to correct standalone page" do
    invite = invites(:page)
    callback = 'jsfeed'
    page = invite.page
    assert page.site.blank?, "We're testing a standalone page here"
    content = "HUH THIS SITE IS LAME YO"

    assert_difference "page.feedbacks.count" do
      assert_no_difference "Page.count" do
        post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
             :current_page => page.url, :callback => callback, :content => content, :target => "html"
      end
    end

    feedback = page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => page.url
  end
  
  test "should neither add new feedback nor create new Pages when invited to a Page instead of a Site" do
    invite = invites(:page)
    callback = 'jsfeed'
    page = invite.page
    assert page.site.blank?, "We're testing a standalone page here"
    content = "derrrrrr"
    
    assert_no_difference "page.feedbacks.count", "Page.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "html",
          :current_page => page.url + "/lolololol", :callback => callback, :content => content, :target => "html"
    end
    
    validate_post_fail
  end
  
  test "should render an html template when posting and format=html" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :current_page => page.url,
           :callback => callback, :content => content, :target => "html", :windowname => "true", :format => "html" 
    end
    
    assert_template "new_feedback_for_page"
    feedback = page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    validate_windowname :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  
  test "should destroy feedback" do
    feedback = feedbacks(:one)
    page = feedback.page
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => feedback.id
    end
    assert_redirected_to page_path(page)
  end
  
  test "should add new threaded feedback for page" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
	  parent = page.feedbacks.first
    content = "replying to first feedback a;lkjsdflkasdjfla"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html", :parent_id => parent.id
    end
    parent.reload
    assert parent.children.first.content == content
   
    feedback = page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should be able to post public comments" do
    page = pages(:transactions)
    content = "HUH THIS SITE IS LAME YO"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :current_page => page.url, :name => "Joe Schmoe",
           :content => content, :target => "html", :windowname => "true", :format => "html" 
    end
    assert_template "new_feedback_for_page"
    feedback = page.feedbacks.map { |f| f.json_attributes(nil) }
    validate_windowname :authorized => true, :feedback => feedback, :url => page.url
  end
  
  test "can't post public comments without a name" do
    page = pages(:transactions)
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :current_page => page.url,
           :content => content, :target => "html", :windowname => "true", :format => "html" 
    end
    validate_post_fail
  end

  test "should not post public comments to pages with public comments disabled" do
    page = pages(:one)
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :current_page => page.url, :name => "Joe Schmoe",
           :content => content, :target => "html", :windowname => "true", :format => "html" 
    end
    validate_post_fail
  end
  
  test "can post to a new page in a public site" do 
    page_url = "http://localhost:3001/asite/puppies.html"
    content = "I like puppies"
    assert_difference "Page.count" do
      post :new_feedback_for_page, :current_page => page_url, :name => "Joe Schmoe",
           :content => content, :target => "html", :windowname => "true", :format => "html" 
    end
    assert_template "new_feedback_for_page"
  end
  
  test "can get feedback for public page without url_token" do 
    page = pages(:transactions)
    callback = "calljs"
    assert page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    get :feedback_for_page, :current_page => page.url, :callback => callback
    feedback = page.feedbacks.map { |f| f.json_attributes(nil) }

    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => page.url
  end
  
  test "authorized for feedback from page in public site even if no feedback on page" do 
    page = pages(:public_site)
    callback = "calljs"
    get :feedback_for_page, :current_page => page.url + "lolcats.html", :callback => callback
    feedback = []
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => page.url
  end
  
  test "not authorized for public site with bad url token" do 
    page = pages(:public_site)
    callback = "calljs"
    get :feedback_for_page, :current_page => page.url + "lolcats.html", 
        :callback => callback, :url_token => "lolcats"
    feedback = []
    validate_json :callback => callback, :authorized => false
  end
  
end
