require File.dirname(__FILE__) + '/../../test_helper'

class Widget::UserStylesControllerTest < ActionController::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO:
  # The following are largely duplicated in 
  # Widget::FeedbacksController and Widget::OpinionsController
  # and won't be repeated here because they should be refactored into
  # Widget::WidgetControllerTest
  # 
  # test "should not allow page edits for an invalid URL token"
  # test "should not allow page edits given an invalid page"
  # test "should not allow page edits given a callback that's not a valid JavaScript function name"
  # test "should not allow page edits given invalid opinion values"
  # test "should not allow page edits with an invalid feedback id"
  # <end of test cases to be refactored>

  test "should fetch a list of page edits" do
    
  end
  
  test "should create a new page edit" do
    
  end

end
