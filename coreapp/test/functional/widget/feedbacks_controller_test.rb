require File.dirname(__FILE__) + '/../../test_helper'

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
    
    validate_json :callback => callback, :authorized => false, :admin => false, :feedback => feedback
  end
  
  test "should not list feedback for an invalid page" do
    invite = invites(:one)
    callback = "rofflecopter"
    feedback = []
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => 'bullshit', :callback => callback
    
    validate_json :callback => callback, :authorized => false, :admin => false, :feedback => feedback
  end

  test "should not list feedback for a page a commenter hasn't been invited to" do
    invite = invites(:one)
    callback = "rofflecopter"
    feedback = []
    uninvited_page_url = invites(:page).page.url

    get :feedback_for_page, :url_token => invite.url_token, :current_page => uninvited_page_url, :callback => callback
    
    validate_json :callback => callback, :authorized => false, :admin => false, :feedback => feedback
  end
  
  test "should render an empty list of feedback for a valid page that doesn't exist" do
    invite = invites(:quentin_admin_msn)
    callback = 'rover'
    feedback = []
    page_url = "http://" + URI.parse(invites(:one).page.url).host + "/nowayinhellshouldthisbeinourfixtures.xhtml"
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => page_url,
        :callback => callback, :email => "quentin@example.com", :password => "monkey"
    
    validate_json :callback => callback, :authorized => true,
                  :admin => invite.page.site.validation_token, :feedback => feedback
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


  test "should list all feedback for admin" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    feedback = invite.page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
    
    assert invite.page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url,
        :callback => callback, :email => "quentin@example.com", :password => "monkey"
    
    validate_json :callback => callback, :authorized => true,
                  :admin => invite.page.site.validation_token, :feedback => feedback
  end

  test "should list feedback for page for user" do
    invite = invites(:page)
    callback = 'jsfeed'
    
    feedback = []
    assert invite.page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    for fb in invite.page.feedbacks.roots do
      if !fb.private || fb.commenter == invite.commenter
        feedback += fb.self_and_descendants
      end
    end
    feedback = feedback.map { |f| f.json_attributes(invite.commenter) }
    #feedback = invite.page.feedbacks.find(:all, :conditions => 
    #           [ "private = ? OR commenter_id = ?", false, invite.commenter_id ]).map { |f| f.json_attributes(invite.commenter) }

    get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url,
        :callback => callback
    
    validate_json :callback => callback, :authorized => true, :feedback => feedback
  end
  
  test "should add new feedback for page" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html",
          :email => "quentin@example.com", :password => "monkey"
    end

    validate_json :callback => callback, :authorized => true, :admin => page.site.validation_token, :success => true
  end

  test "should return appropriate comments after feedback is given" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"

    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
           :current_page => page.url, :callback => callback, :content => content, :target => "html",
           :isPrivate => false
    end

    feedback = []
    for fb in page.feedbacks.roots do
      if !fb.private || fb.commenter == invite.commenter
        feedback += fb.self_and_descendants
      end
    end
    feedback = feedback.map { |f| f.json_attributes(invite.commenter) }

    validate_json :callback => callback, :authorized => true, :success => true, :feedback => feedback
  end
  
  test "should create new page when adding feedback for new url" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    new_url = page.url + "/ASDFWUTLOL.asp.html"
    
    assert_difference "Page.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => new_url, :callback => callback, :content => content, :target => "html",
          :email => "quentin@example.com", :password => "monkey"
    end
    new_page = Page.find_by_url new_url
    assert ! new_page.nil?, "page was created successfully"
    assert new_page.feedbacks.count == 1, "feedback was attached to new page"

    validate_json :callback => callback, :authorized => true, :admin => page.site.validation_token, :success => true
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
    
    validate_json :callback => callback, :authorized => false, :admin => false, :success => false
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
  
  test "should render an html template when posting and format=html" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :current_page => page.url,
           :callback => callback, :content => content, :target => "html", :windowname => "true",
           :format => "html", :email => "quentin@example.com", :password => "monkey"
    end
    
    assert_template "new_feedback_for_page"
    validate_windowname :authorized => true, :admin => page.site.validation_token, :success => true
  end
  
  
  test "should destroy feedback" do
    feedback = feedbacks(:one)
    page = feedback.page
    page.site.new_validation_token
    invite = invites(:quentin_admin_msn)
    url_token = invite.url_token
    callback = 'deleted_comment'
    validation_token = invite.page.site.validation_token
    assert_difference('Comment.count', -1) do
      post :destroy, :id => feedback.id, :url_token => url_token, :validation_token => validation_token,
        :current_page => feedback.page.url, :callback => callback
    end
    validate_windowname :authorized => true, :admin => page.site.validation_token, :success => true
  end
  
  test "should add new threaded feedback for page" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    page = invite.page
	  parent = page.feedbacks.first
    content = "replying to first feedback a;lkjsdflkasdjfla"
    
    assert_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html",
          :parent_id => parent.id, :email => "quentin@example.com", :password => "monkey"
    end
    parent.reload
    assert parent.children.first.content == content

    validate_json :callback => callback, :authorized => true, :admin => page.site.validation_token, :success => true
  end
  
  test "cannot reply to deleted comment" do
    invite = invites(:quentin_admin_msn)
    callback = 'jsfeed'
    page = invite.page
	  parent = page.feedbacks.first
    content = "replying to first feedback a;lkjsdflkasdjfla"
    
    parent.destroy
    
    assert_no_difference "page.feedbacks.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html",
          :parent_id => parent.id, :email => "quentin@example.com", :password => "monkey"
    end
    
    validate_json :callback => callback, :authorized => true, :admin => page.site.validation_token, :success => false
  end
  
  test "login flows" do
    commenter = commenters(:one)
    admin = create_account({:email => '1@ex.com', :password => 'test123', :password_confirmation => 'test123'})
    site = create_site({:account => admin})
    site = Site.find(site.id)
    site.save
    page = site.home_page
    create_invite({:commenter => commenter, :page => page})
    create_invite({:commenter => admin, :page => page})
    commenter_url_token = Invite.find_by_commenter_id(commenter.id).url_token
    admin_url_token = Invite.find_by_commenter_id(admin.id).url_token
    callback = "callback"

    assert_nil site.validation_token
    current_validation_token = site.validation_token
    last_validation_token = nil

    # url_token, url_token not valid, commenter url_token
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => commenter_url_token + "blah"
    site.reload
    validate_json :callback => callback, :authorized => false, :admin => false

    # url_token, url_token not valid, admin url_token
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token + "blah"
    site.reload
    validate_json :callback => callback, :authorized => false, :admin => false

    # url_token, url_token valid, commenter url_token
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => commenter_url_token
    site.reload
    validate_json :callback => callback, :authorized => true, :admin => false

    # url_token, url_token valid, admin url_token, email & password, email & password valid
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token, :email => '1@ex.com', :password => 'test123'
    site.reload
    validate_json :callback => callback, :authorized => true, :admin => site.validation_token
    last_validation_token = current_validation_token
    current_validation_token = site.validation_token

    # url_token, url_token valid, admin url_token, email & password, email & password invalid
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token, :email => '1@ex.com', :password => 'blah'
    site.reload
    validate_json :callback => callback, :authorized => false, :admin => false
    assert site.validation_token == current_validation_token

    # url_token, url_token valid, admin url_token
    # validation_token, validation_token valid, timestamp fine
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token, :validation_token => current_validation_token
    site.reload
    validate_json :callback => callback, :authorized => true, :admin => site.validation_token
    assert site.validation_token == current_validation_token

    # url_token, url_token valid, admin url_token
    # validation_token, validation_token valid, timestamp too old
    fake_timestamp = 5.hours.ago
    site.validation_timestamp = fake_timestamp
    site.save
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token, :validation_token => current_validation_token
    site.reload
    validate_json :callback => callback, :authorized => true, :admin => site.validation_token
    assert site.validation_token != current_validation_token
    assert site.validation_timestamp != fake_timestamp
    last_validation_token = current_validation_token
    current_validation_token = site.validation_token

    # url_token, url_token valid, admin url_token
    # validation_token, validation_token invalid
    get :feedback_for_page, :current_page => page.url, :callback => callback,
        :url_token => admin_url_token, :validation_token => last_validation_token
    site.reload
    validate_json :callback => callback, :authorized => false, :admin => false
    assert site.validation_token != current_validation_token
  end

  def test_return_site_id_if_admin
    invite = invites(:quentin_admin_msn)
    page = invite.page
    correct_site_id = page.site.id
    get :feedback_for_page, :current_page => page.url, :callback => "callback",
        :url_token => invite.url_token, :email => "quentin@example.com",
        :password => "monkey"
    page.site.reload
    validate_json :callback => "callback", :authorized => true, :admin => page.site.validation_token,
                  :site_id => correct_site_id
  end

  def test_dont_return_site_id_after_first_call_if_admin
    invite = invites(:quentin_admin_msn)
    page = invite.page
    correct_site_id = page.site.id
    get :feedback_for_page, :current_page => page.url, :callback => "callback",
        :url_token => invite.url_token, :site_id => correct_site_id,
        :email => "quentin@example.com", :password => "monkey"
    page.site.reload
    validate_json :callback => "callback", :authorized => true, :admin => page.site.validation_token
    json = get_json("callback")
    assert !json[:site_id], "site_id should not be present in the returned JSON, received #{json[:site_id].inspect}"
  end

  def test_dont_return_site_id_if_not_admin
    invite = invites(:page)
    page = invite.page
    assert page.account != invite.commenter
    get :feedback_for_page, :current_page => page.url, :callback => "callback", :url_token => invite.url_token
    json = get_json("callback")
    assert !json[:site_id], "site_id should not be present in the returned JSON, received #{json[:site_id].inspect}"
  end

  def test_should_indicate_one_admin_account_commenter_if_none_have_been_invited
    invite = invites(:aaron_admin_facebook)
    assert invite.page.site.commenters.length == 1, "The only commenter on this site should be the admin"
    assert invite.page.account == invite.commenter, "The commenter of the invite should be the admin"

    get :feedback_for_page, :current_page => invite.page.url, :callback => "callback",
        :url_token => invite.url_token, :email => "aaron@example.com", :password => "monkey"
    invite.reload
    validate_json :callback => "callback", :authorized => true, :admin => invite.page.site.validation_token,
                  :feedback => [], :no_commenters => true
  end

  def test_should_not_indicate_no_commenters_if_commenters_exist
    invite = invites(:quentin_admin_msn)
    assert invite.page.site.commenters.length > 1, "The site should have at least one commenter aside from the admin"
    get :feedback_for_page, :current_page => invite.page.url, :callback => "callback",
        :url_token => invite.url_token, :email => "quentin@example.com", :password => "monkey"
    invite.reload
    validate_json :callback => "callback", :authorized => true, :admin => invite.page.site.validation_token
    json = get_json("callback")
    assert !json[:no_commenters]
  end

end
