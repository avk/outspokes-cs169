require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  test "should get index" do
    login_as nil
    get :index
    assert_response :success
  end

  # test "should be able to log in" do
  #     login_as(:quentin)
  #     get :dashboard, :controller => :accounts
  #     assert_response :success
  #     assert assigns(:sites), commenters(:quentin).sites
  #   end
end
