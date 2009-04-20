require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  test "should get index" do
	login_as nil
    get :index
    assert_response :success
	assert assigns(:sites), Site.find(:all)
	assert assigns(:pages), Page.find_all_by_site_id(nil)
  end

  test "should be able to log in" do
    login_as(:quentin)
	get :index
    assert_response :success
    assert assigns(:sites), commenters(:quentin).sites
	assert assigns(:pages), commenters(:quentin).pages
  end
end
