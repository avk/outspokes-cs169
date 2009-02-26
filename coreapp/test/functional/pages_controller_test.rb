require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, :page => valid_options_for_page_account
    end
    assert_redirected_to page_path(assigns(:page))
  end
  
  test "should go back to new when trying to create an invalid page" do
    unless valid_options_for_page_account.empty?
      assert_no_difference('Site.count') do
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
    get :edit, :id => pages(:one).id
    assert_response :success
  end

  test "should update page" do
    # SUBTLETY: Don't know if page has a site or account, so can't set the site or account
    # to test without checking ... so just update url
    put :update, :id => pages(:one).id, :page => { :url => "http://google.com" }
    assert_redirected_to page_path(assigns(:page))
  end
  
  test "should go back to edit if updating a page with invalid parameters" do
    unless valid_options_for_page_account.keys.empty?
      put :update, :id => pages(:one).id, :page => { valid_options_for_page_account.keys.first => nil }
      assert_template "edit"
    end
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, :id => pages(:one).id
    end

    assert_redirected_to pages_path
  end
end
