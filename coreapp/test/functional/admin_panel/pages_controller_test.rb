require File.dirname(__FILE__) + '/../../test_helper'

class AdminPanel::PagesControllerTest < ActionController::TestCase

  def setup
    @site = sites(:linkedin)
    @site.new_validation_token
    @alt_site = sites(:facebook)
  end
  
  def assert_invalid
    assert !flash[:error].nil?
    assert_template "admin_panel/invalid"
  end
  
  test "should list a site's pages" do
    get :index, :site_id => @site.id, :validation_token => @site.validation_token
    assert @site.pages_with_latest_feedback == assigns(:pages)
  end
  
  test "should not list a site's pages given an invalid validation_token" do
    get :index, :site_id => @site.id, :validation_token => 'bullshit'
    assert_invalid
  end
  
  test "should not list anything for an invalid site id" do
    get :index, :site_id => '9870809870098242342349142309874023', :validation_token => @site.validation_token
    assert_invalid
  end
  
  test "should not list the pages of someone else's site" do
    get :index, :site_id => @alt_site, :validation_token => @site.validation_token
    assert_invalid
  end
  
  test "should not destroy anything when given an id for a page that doesn't exist" do
    page_id = @site.pages.last.id + 69
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => @site.id, :id => page_id, :validation_token => @site.validation_token
    end
    assert_invalid
  end
  
  test "should not destroy anything when given an id for a site that doesn't exist" do
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => 0, :id => 69, :validation_token => @site.validation_token # :id doesn't matter
    end
    assert_invalid
  end
  
  test "should not destroy anything when given an invalid validation_token" do
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => @site.id, :id => 69, :validation_token => 'bullshit'
    end
    assert_invalid
  end
  
  test "should not destroy someone else's pages" do
    assert_no_difference "Page.count" do
      delete :destroy, :site_id => @alt_site.id, :id => @alt_site.pages.last, :validation_token => @site.validation_token
    end
    assert_invalid
  end
  
  test "should destroy page" do
    assert_difference "Page.count", -1 do
      delete :destroy, :site_id => @site.id, :id => @site.pages.first, :validation_token => @site.validation_token
    end
    assert_redirected_to admin_panel_site_pages_path(@site)
  end

end
