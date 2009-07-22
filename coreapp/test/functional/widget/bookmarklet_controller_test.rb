require File.dirname(__FILE__) + '/../../test_helper'

class Widget::BookmarkletControllerTest < ActionController::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def coming_from(url)
    @request.env['HTTP_REFERER'] = url
  end
  
  test "should require login" do
    get :index
    assert_template 'login'
  end
  
  test "should create a new site if called from a URL of a site that's not yours" do
    login_as :aaron
    coming_from "http://cantpossiblybeasiteicontrol.gd"
    
    assert_difference "Site.count", 1 do
      get :index, :format => :js
    end
    
    new_site = Site.last
    assert new_site.account == commenters(:aaron)
    assert assigns(:site) == new_site
    assert assigns(:url_token) == new_site.admin_url_token
  end
  
  test "should not create a new site if called from a URL that has frames" do
    login_as :aaron
    coming_from "http://www.opensourcetemplates.org/templates/preview/1361070670/"
    
    assert_no_difference "Site.count" do
      # params[:has_frames] would be set by the bookmarklet code before hitting BookmarkletController#index
      get :index, :format => :js, :has_frames => true
    end
    
    assert assigns(:frames) == true
    assert assigns(:site).nil?
    assert assigns(:url_token).nil?
  end
  
  # test "should create a new page if called from a URL that matches one of your sites but not any existing page" do
  #   login_as :aaron
  #   admin = commenters(:aaron)
  #   site = admin.sites.first
  #   url = site.url + '/ireallyhope/thisdoesntexist/onthissite.html'
  #   coming_from url
  #   
  #   assert_no_difference "Site.count" do
  #     assert_difference "Page.count", 1 do
  #       get :index, :format => :js
  #     end
  #   end
  #   
  #   new_page = Page.last
  #   assert new_page.url == url
  #   assert assigns(:site) == site
  #   assert assigns(:url_token) == site.admin_url_token
  # end
  
  test "should not create a new page if called from a URL that matches one of your sites and one of its pages" do
    login_as :aaron
    page = pages(:myspace_tour)
    site = page.site
    coming_from page.url
    
    assert_no_difference "Site.count" do
      assert_no_difference "Page.count" do
        get :index, :format => :js
      end
    end
    
    assert assigns(:site) == site
    assert assigns(:url_token) == site.admin_url_token
  end

end
