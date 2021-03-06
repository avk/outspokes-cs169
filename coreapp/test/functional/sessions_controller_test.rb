require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase

  def test_should_login_and_redirect
    post :create, :email => 'quentin@example.com', :password => 'monkey'
    assert session[:account_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    assert_nil session[:account_id]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:account_id]
    assert_response :redirect
  end

  def test_should_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :email => 'quentin@example.com', :password => 'monkey', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :email => '@example.com', :password => 'monkey', :remember_me => "0"
    puts @response.cookies["auth_token"]
    assert @response.cookies["auth_token"].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  def test_should_login_with_cookie
    commenters(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    commenters(:quentin).remember_me
    commenters(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    commenters(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  def test_should_record_each_successful_login
    admin = commenters(:aaron)
    old_updated_at = admin.updated_at
    post :create, :email => 'aaron@example.com', :password => 'monkey'
    admin.reload
    new_updated_at = admin.updated_at
    assert new_updated_at > old_updated_at
  end
  

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(account)
      auth_token commenters(account).remember_token
    end
end
