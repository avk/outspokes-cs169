require 'test_helper'

class SitesControllerTest < ActionController::TestCase
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

    assert_redirected_to page_path(assigns(:site).home_page)
  end

  test "not logged in should not create site" do
    assert_no_difference('Site.count') do
      post :create, :site => valid_options_for_site
    end

    assert_redirected_to new_session_path
  end

  ### Sites only need accounts to be valid; since SitesController#create associates the logged in account
  ### with the newly created site, it is currently impossible for a logged in user to fail to create a
  ### site
  # test "should go back to new when trying to create an invalid site" do
  #   login_as :quentin
  #   unless valid_options_for_site.empty?
  #     assert_no_difference('Site.count') do
  #       post :create, :site => invalid_options_for_site
  #     end
  #   
  #     assert_template "new"
  #   end
  # end

  test "should get edit" do
    login_as :quentin
    get :edit, :id => sites(:linkedin).id
    assert_response :success
  end

  test "not logged in should not edit site" do
    get :edit, :id => sites(:linkedin).id

    assert_redirected_to new_session_path
  end


  # TODO: Not sure about these tests, as a site's home_page shouldn't be updated, right??
  
  #   test "should update site" do
  # login_as :quentin
  # url = "http://www.facebook.com"
  #     put :update, :id => sites(:linkedin).id, :site => { :url => url }
  # assert assigns(:site).url == url
  #     assert_redirected_to site_path(assigns(:site))
  #   end

    test "should not update site if not logged in" do
#      url = "http://www.facebook.com"
      account = commenters(:aaron)
      put :update, :id => sites(:linkedin).id, :site => { :account_id => account.id }
      site = Site.find(sites(:linkedin).id) 
      assert account.object_id != id
      assert_redirected_to new_session_path
    end
  
  
    test "should go back to edit if updating an site with invalid parameters" do
      login_as :quentin
      unless valid_options_for_site.keys.empty?
        put :update, :id => sites(:linkedin).id, :site => { :account => nil }
        assert_template "edit"
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
