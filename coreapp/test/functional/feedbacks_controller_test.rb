require 'test_helper'
require 'json'

class FeedbacksControllerTest < ActionController::TestCase

  def setup
    @controller = FeedbacksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    # from: http://www.quackit.com/javascript/javascript_reserved_words.cfm
    @js_keywords = %w(
    break continue do for import new this void
    case default else function in return typeof while
    comment delete export if label switch var with
    abstract implements protected
    boolean instanceOf public
    byte int short
    char interface static
    double long synchronized
    false native throws
    final null transient
    float package true
    goto private
    catch enum throw
    class extends try
    const finally
    debugger super
    alert eval Link outerHeight scrollTo
    Anchor FileUpload location outerWidth Select
    Area find Location Packages self
    arguments focus locationbar pageXoffset setInterval
    Array Form Math pageYoffset setTimeout
    assign Frame menubar parent status
    blur frames MimeType parseFloat statusbar
    Boolean Function moveBy parseInt stop
    Button getClass moveTo Password String
    callee Hidden name personalbar Submit
    caller history NaN Plugin sun
    captureEvents History navigate print taint
    Checkbox home navigator prompt Text
    clearInterval Image Navigator prototype Textarea
    clearTimeout Infinity netscape Radio toolbar
    close innerHeight Number ref top
    closed innerWidth Object RegExp toString
    confirm isFinite onBlur releaseEvents unescape
    constructor isNan  onError Reset untaint
    Date java onFocus resizeBy unwatch
    defaultStatus JavaArray onLoad resizeTo valueOf
    document JavaClass onUnload routeEvent watch
    Document JavaObject open scroll window
    Element JavaPackage opener scrollbars Window
    escape length Option scrollBy
    )
  end
  
  def validate_json(args)
    callback = args.delete(:callback)
    
    # make sure the response is wrapped in the callback
    assert @response.body.match("^#{callback}\\(\\{"), "Expecting callback #{callback} but it wasn't found!"
    
    # get at just the JSON data (i.e. strip the JS callback wrapping it)
    json = @response.body.sub("#{callback}(", '').sub(/\);?/, '')
    validate_json_vals(json, args)
  end
  
  def validate_post_fail
    json_string = @response.body.match(/.*window.name='(.+)'/)[1]
    obj = JSON.parse(json_string)
    assert obj["authorized"] == false, "Should return json with authorized:false if post fails. Instead got: #{obj.inspect}"
  end
  
  # no callback when using windowname
  def validate_windowname(args)
     json_string = @response.body.match(/.*window.name='(.+)'/)[1]
     validate_json_vals(json_string, args)
  end
  
  def validate_json_vals(json_string, intended)
    # e.g. assert json['authorized'] == true
    json = JSON.parse(json_string)
    intended.each do |field_name, field_value|
      assert json[field_name.to_s] == field_value, "#{field_name} is set to #{json[field_name.to_s].inspect} instead of #{field_value.inspect}"
    end
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
    # keywords = %w(window open location string document with case alert)
    spaces = ['no spaces']
    
    illegal_callbacks = illegal_chars + @js_keywords + spaces
    illegal_callbacks.each do |callback|
      get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback, :format => "js"
      assert @response.body == '{}'
    end
  end

  test "should list feedback for page" do
    invite = invites(:one)
    callback = 'jsfeed'
    feedback = invite.page.feedbacks.map { |f| f.json_attributes }
    
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
    
    feedback = page.feedbacks.map { |f| f.json_attributes }
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
    
    feedback = new_page.feedbacks.map { |f| f.json_attributes }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should not add new feedback for page for an invalid URL token" do
    invite = invites(:one)
    callback = 'jsfeed'
    page = invite.page
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "Feedback.count" do
      post :new_feedback_for_page, :url_token => "LOL!!!!!", :format => "js", 
          :current_page => page.url, :callback => callback, :content => content, :target => "html"
    end
    
    validate_json :callback => callback, :authorized => false
  end
  
  test "should not add new feedback to an invalid page" do
    invite = invites(:one)
    callback = 'jsfeed'
    content = "HUH THIS SITE IS LAME YO"
    
    assert_no_difference "Feedback.count" do
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
    
    illegal_callbacks = illegal_chars + @js_keywords + spaces
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
    
    assert_no_difference "Feedback.count" do
      post :new_feedback_for_page, :url_token => invite.url_token, :format => "html", 
          :current_page => page.url, :callback => callback, :content => '', :target => "html"
    end
    
    validate_post_fail
  end

  test "should not add new feedback that has no target" do
    invite = invites(:one)
    page = invite.page
    callback = 'jsfeed'
    
    assert_no_difference "Feedback.count" do
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

    feedback = page.feedbacks.map { |f| f.json_attributes }
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
    feedback = page.feedbacks.map { |f| f.json_attributes }
    validate_windowname :authorized => true, :feedback => feedback, :url => invite.page.url
  end
  
  test "should destroy feedback" do
    feedback = feedbacks(:one)
    page = feedback.page
    assert_difference('Feedback.count', -1) do
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
    
    feedback = page.feedbacks.map { |f| f.json_attributes }
    validate_json :callback => callback, :authorized => true, :feedback => feedback, :url => invite.page.url
  end
end
