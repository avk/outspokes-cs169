require 'test_helper'
require 'json'

class FeedbacksControllerTest < ActionController::TestCase

  def setup
    @controller = FeedbacksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def fix_date_fields(feedback)
    # fix the date fields because the JSON gem doesn't convert them back into the native Ruby format
    date_columns = []
    Feedback.columns.each {|c| date_columns << c.name if c.type.to_s.match /date|time|datetime|timestamp/ }
    date_columns.each do |date_field|
      feedback.each {|c| c[date_field] = c[date_field].to_json.gsub("\"", '') }
    end
    feedback
  end
  
  def validate_json(args)
    callback = args.delete(:callback)
    
    # make sure the response is wrapped in the callback
    assert @response.body.match "^#{callback}\\(\\{"
    
    # get at just the JSON data (i.e. strip the JS callback wrapping it)
    json = @response.body.sub("#{callback}(", '').sub(/\);/, '')
    json = JSON.parse(json)
    
    # e.g. assert json['authorized'] == true
    args.each do |field_name, field_value|
      assert json[field_name.to_s] == field_value
    end
  end
  
  
  
  test "should not list feedback for an invalid URL token" do
    invite = invites(:one)
    callback = 'doesntmatter'
    feedback = []
    
    get :feedback_for_page, :url_token => 'bullshit', :current_page => invite.page.url, :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback
  end
  
  test "should not list feedback for an invalid page" do
    invite = invites(:one)
    callback = 'doesntmatter'
    feedback = []
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => 'bullshit', :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback
  end

  test "should not list feedback for a page a commenter hasn't been invited to" do
    invite = invites(:one)
    callback = 'notinvited'
    feedback = []
    uninvited_page_url = Page.find(:first, :conditions => [ "id != ?", invite.page.id ]).url
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => uninvited_page_url, :callback => callback
    
    validate_json :callback => callback, :authorized => false, :feedback => feedback
  end
  
  test "should render an empty list of feedback for a valid page that doesn't exist" do
    invite = invites(:one)
    callback = 'rover'
    feedback = []
    page_url = "http://" + URI.parse(invites(:one).page.url).host + "/nowayinhellshouldthisbeinourfixtures.xhtml"
    
    get :feedback_for_page, :url_token => invite.url_token, :current_page => page_url, :callback => callback
    
    validate_json :callback => callback, :authorized => true, :feedback => feedback
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
    feedback = invite.page.feedbacks.map { |f| f.public_attributes }
    
    assert invite.page.feedbacks.size > 0, "your feedbacks fixtures don't have enough data for this test"
    get :feedback_for_page, :url_token => invite.url_token, :current_page => invite.page.url, :callback => callback
    
    feedback = fix_date_fields(feedback)
    validate_json :callback => callback, :authorized => true, :feedback => feedback
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
