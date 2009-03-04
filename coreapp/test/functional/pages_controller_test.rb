require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test "should not load new if not logged in" do
    get :new
    assert_redirected_to new_session_path
  end

  test "should load new if logged in" do
    login_as :quentin
    get :new
    assert_response :success
  end

  test "should create page" do
    login_as :quentin
    assert_difference('Page.count') do
      post :create, :page => valid_options_for_page_account
    end
    assert_redirected_to page_path(assigns(:page))
  end

  test "not logged in should not create page" do
    assert_no_difference('Page.count') do
      post :create, :page => valid_options_for_page_account
    end

    assert_redirected_to new_session_path
  end

  test "should go back to new when trying to create an invalid page" do
	login_as :quentin    
	unless invalid_options_for_page.empty?
      assert_no_difference('Page.count') do
        post :create, :page => invalid_options_for_page
      end 
      assert_template "new"
    end
  end

  test "should show page" do
    get :show, :id => pages(:one).id
    assert_response :success
  end

  test "should get edit" do
    login_as :quentin
    get :edit, :id => pages(:one).id
    assert_response :success
  end

  test "not logged in should not edit page" do
    get :edit, :id => pages(:two).id

    assert_redirected_to new_session_path
  end

  test "should update page" do
    # SUBTLETY: Don't know if page has a site or account, so can't set the site or account
    # to test without checking ... so just update url
    login_as :quentin    
    put :update, :id => pages(:one).id, :page => { :url => "http://google.com" }
    assert_redirected_to page_path(assigns(:page))
  end

  test "should not update page if not logged in" do
    url = "http://www.facebook.com"
    put :update, :id => pages(:two).id, :page => { :url => url }
    page = Page.find(pages(:two).id)	
    assert page.url != url
    assert_redirected_to new_session_path
  end

  test "should go back to edit if updating a page with invalid parameters" do
    login_as :quentin
    unless valid_options_for_page_account.keys.empty?
      put :update, :id => pages(:one).id, :page => { :url => nil }
      assert_template "edit"
    end
  end

  test "should destroy page" do
    login_as :quentin
    assert_difference('Page.count', -1) do
      delete :destroy, :id => pages(:one).id
    end

    assert_redirected_to root_path
  end

  test "should not destroy page if not logged in" do
    assert_no_difference('Page.count') do
      delete :destroy, :id => pages(:one).id
    end

    assert_redirected_to new_session_path
  end
end
