require File.dirname(__FILE__) + '/../../test_helper'

class AdminPanel::PagesControllerTest < ActionController::TestCase

  # test "should not list a site's pages if not logged in" do
  #   get :index, :site_id => sites(:linkedin).id
  #   assert_redirected_to new_session_path # TODO: show unathorized action ?
  # end
  # 
  # test "should not list someone else's site's pages" do
  #   # aaron is NOT the creator of linkedin
  #   login_as :aaron
  #   get :index, :site_id => sites(:linkedin).id
  # end
  # 
  # test "should list a site's pages if the site creator is logged in" do
  # end

  # TODO add authentication tests

  def assert_invalid
    assert !flash[:error].nil?
    assert_template "admin_panel/invalid"
  end
  

  test "should list a site's pages" do
    site = sites(:linkedin)
    get :index, :site_id => site.id
    assert site.pages_with_latest_feedback == assigns(:pages)
  end
  
  test "should not list anything for an invalid site id" do
    get :index, :site_id => '9870809870098242342349142309874023'
    assert_invalid
  end
  
  test "should not destroy anything when given an id for a page that doesn't exist" do
    site = sites(:linkedin)
    page_id = site.pages.last.id + 69
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => site.id, :id => page_id
    end
    assert_invalid
  end
  
  test "should not destroy anything when given an id for a site that doesn't exist" do
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => 0, :id => 69 # :id doesn't matter
    end
    assert_invalid
  end
  
  test "should destroy page" do
    site = sites(:linkedin)
    assert_difference "Page.count", -1 do
      delete :destroy, :site_id => site.id, :id => site.pages.first
    end
    assert_redirected_to admin_panel_site_pages_path(site)
  end

end
