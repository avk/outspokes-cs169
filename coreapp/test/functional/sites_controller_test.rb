require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site" do
    assert_difference('Site.count') do
      post :create, :site => valid_options_for_site
    end

    assert_redirected_to site_path(assigns(:site))
  end

  test "should go back to new when trying to create an invalid site" do
    unless valid_options_for_site.empty?
      assert_no_difference('Site.count') do
        post :create, :site => invalid_options_for_site
      end
    
      assert_template "new"
    end
  end


  test "should show site" do
    get :show, :id => sites(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => sites(:one).id
    assert_response :success
  end

  test "should update site" do
    put :update, :id => sites(:one).id, :site => valid_options_for_site
    assert_redirected_to site_path(assigns(:site))
  end

  test "should go back to edit if updating an site with invalid parameters" do
    unless valid_options_for_site.keys.empty?
      put :update, :id => sites(:one).id, :site => { valid_options_for_site.keys.first => nil }
      assert_template "edit"
    end
  end

  test "should destroy site" do
    assert_difference('Site.count', -1) do
      delete :destroy, :id => sites(:one).id
    end

    assert_redirected_to sites_path
  end
end
