require 'test_helper'

class Widget::SourceControllerTest < ActionController::TestCase

  def setup 
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new 
  end 

  test "should fetch widget code" do
    get :index, :id => Site.first.id
    assert_response :success
    assert_equal 'text/javascript; charset=utf-8', @response.headers['type']
    assert_not_nil assigns(:fb_hash)
  end
end
