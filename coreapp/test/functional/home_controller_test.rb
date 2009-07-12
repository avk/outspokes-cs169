require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  test "should get index" do
    login_as nil
    get :index
    assert_response :success
  end

  test "should set timezone if account is logged in" do
    login_as :quentin

    assert_equal 'UTC', Time.zone
    get :index
    assert_equal 'Pacific Time (US & Canada)', Time.zone
  end

  test "should not set timezone if not logged in" do
    assert_equal 'UTC', Time.zone
    get :index
    assert_equal nil, Time.zone
  end

end
