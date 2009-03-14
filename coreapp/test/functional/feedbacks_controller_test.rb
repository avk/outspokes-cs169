require 'test_helper'
require 'json'

class FeedbacksControllerTest < ActionController::TestCase

  def setup
    @controller = FeedbacksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def gimme_json(callback)
    # make sure the response is wrapped in the callback
    assert @response.body.match "^#{callback}\\(\\{"
    
    # get at just the JSON data (i.e. strip the JS callback wrapping it)
    json = @response.body.sub("#{callback}(", '').sub(/\);/, '')
    json = JSON.parse(json)
  end
  
  def fix_date_fields(comments)
    # fix the date fields because the JSON gem doesn't convert them back into the native Ruby format
    date_columns = []
    Feedback.columns.each {|c| date_columns << c.name if c.type.to_s.match /date|time|datetime|timestamp/ }
    date_columns.each do |date_field|
      comments.each {|c| c[date_field] = c[date_field].to_json.gsub("\"", '') }
    end
    comments
  end
  
  
  
  test "should not list feedback for an invalid URL token" do
    invite = invites(:one)
    callback = 'doesntmatter'
    comments = []
    
    get :feedback_for_page, :url_token => 'bullshit', :current_page => invite.page.url, :callback => callback
    
    json = gimme_json(callback)
    assert json['authorized'] == false
    assert json['comments'] == comments
  end
  
  test "should not list feedback for an invalid page" do
    invite = invites(:one)
    callback = 'doesntmatter'
    comments = []
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => 'bullshit', :callback => callback
    
    json = gimme_json(callback)
    assert json['authorized'] == false
    assert json['comments'] == comments
  end

  test "should not list feedback for a page a commenter hasn't been invited to" do
    invite = invites(:one)
    callback = 'notinvited'
    comments = []
    uninvited_page_url = Page.find(:first, :conditions => [ "id != ?", invite.page.id ]).url
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => uninvited_page_url, :callback => callback
    
    json = gimme_json(callback)
    assert json['authorized'] == false
    assert json['comments'] == comments
  end
  
  test "should render an empty list of feedback for a valid page that doesn't exist" do
    invite = invites(:one)
    callback = 'rover'
    comments = []
    page_url = "http://" + URI.parse(invites(:one).page.url).host + "/nowayinhellshouldthisbeinourfixtures.xhtml"
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => page_url, :callback => callback
    
    json = gimme_json(callback)
    assert json['authorized'] == true
    assert json['comments'] == comments
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
    illegal_chars = %w(123 no:colons hash# apo'strope per%cent mult*iply add+ition)
    keywords = []#%w(window open location string document with case hi what)
    spaces = ['no spaces']
    
    illegal_callbacks = illegal_chars + keywords + spaces
    illegal_callbacks.each do |callback|
      get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback
      assert @response.body == '{}'
    end
  end

  test "should list feedback for page" do
    invite = invites(:one)
    callback = 'jsfeed'
    comments = invite.page.feedbacks.map { |f| f.public_attributes }
    
    assert invite.page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback
    
    json = gimme_json(callback)
    assert json['authorized'] == true
    comments = fix_date_fields(comments)
    assert json['comments'] == comments
  end
  
  test "should destroy feedback" do
    feedback = feedbacks(:one)
    page = feedback.page
    assert_difference('Feedback.count', -1) do
      delete :destroy, :id => feedback.id
    end

    assert_redirected_to page_path(page)
  end
end
