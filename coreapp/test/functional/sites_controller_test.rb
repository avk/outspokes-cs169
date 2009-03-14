require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  test "should get new" do
    login_as :quentin
    get :new
    assert_response :success
  end

  test "not not logged in should not get new" do
    get :new
    assert_redirected_to new_session_path
  end

  test "should create site" do
    login_as :quentin
    assert_difference('Site.count') do
      post :create, :site => valid_options_for_site
    end

    assert_redirected_to new_page_commenter_path(assigns(:site).home_page)
  end

  test "not logged in should not create site" do
    assert_no_difference('Site.count') do
      post :create, :site => valid_options_for_site
    end

    assert_redirected_to new_session_path
  end

   test "should go back to new when trying to create an invalid site" do
     login_as :quentin
     unless valid_options_for_site.empty?
       assert_no_difference('Site.count') do
         post :create, :site => invalid_options_for_site
       end
     
       assert_template "new"
     end
   end

  test "should destroy site" do
    login_as :quentin
    assert_difference('Site.count', -1) do
      delete :destroy, :id => sites(:linkedin).id
    end

    assert_redirected_to root_url
  end

  test "should not destroy site if not logged in" do
    assert_no_difference('Site.count') do
      delete :destroy, :id => sites(:linkedin).id
    end

    assert_redirected_to new_session_path
  end

end
