require File.dirname(__FILE__) + '/../test_helper'

class SitesControllerTest < ActionController::TestCase
  
  test "should get new" do
    login_as :quentin
    get :new
    assert_response :success
  end

  test "not logged in should not get new" do
    get :new
    assert_redirected_to new_session_path
  end

  test "should create site" do
    admin = commenters(:quentin)
    login_as :quentin
    
    assert_difference('Site.count') do
      post :create, :site => valid_options_for_site.merge({:account => admin})
      assert assigns(:site).home_page.invites.first.commenter_id == admin.id, "admin has not been invited to his own site"
    end

    assert_redirected_to embed_site_path(assigns(:site)) #dashboard_account_path(admin)
  end

  test "not logged in should not create site" do
    assert_no_difference('Site.count') do
      post :create, :site => valid_options_for_site
    end

    assert_redirected_to new_session_path
  end
=begin
  test "should go back to new when trying to create an invalid site" do
    login_as :quentin
    unless valid_options_for_site.empty?
      assert_no_difference('Site.count') do
        post :create, :site => invalid_options_for_site
      end

      assert_template "new"
    end
  end
=end

  test "should destroy site" do
    login_as :quentin
    site = sites(:linkedin)
    
    assert_difference('Site.count', -1) do
      delete :destroy, :id => site.id
    end

    assert_redirected_to dashboard_account_path(site.account)
  end

  test "should not destroy site if not logged in" do
    assert_no_difference('Site.count') do
      delete :destroy, :id => sites(:linkedin).id
    end

    assert_redirected_to new_session_path
  end
  
  test "public-ness of site == home_page.allow_public_comments" do
    assert sites(:public).public
    assert !sites(:facebook).public
  end

  test "can turn non-public site public and vise-versa" do
    site = sites(:public).public = false
    sites(:public).pages.each do |page|
      assert !page.allow_public_comments
    end
    site = sites(:facebook).public = true
    sites(:facebook).pages.each do |page|
      assert page.allow_public_comments
    end
  end
end
