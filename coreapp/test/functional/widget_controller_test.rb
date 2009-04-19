require 'test_helper'

class WidgetControllerTest < ActionController::TestCase

  def setup 
    @controller = WidgetController.new 
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new 
  end 

  test "should fetch widget code" do
    get :index
    assert_response :success
    assert_equal 'text/javascript; charset=utf-8', @response.headers['type']
    assert_not_nil assigns(:fb_hash)
  end
end
