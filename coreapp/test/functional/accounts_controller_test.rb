require File.dirname(__FILE__) + '/../test_helper'
require 'accounts_controller'

# Re-raise errors caught by the controller.
class AccountsController; def rescue_action(e) raise e end; end

class AccountsControllerTest < ActionController::TestCase

  def test_should_render_signup_form
    get :new
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference 'Account.count' do
      create_account
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'Account.count' do
      create_account(:email => nil)
      assert assigns(:account).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Account.count' do
      create_account(:password => nil)
      assert assigns(:account).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Account.count' do
      create_account(:password_confirmation => nil)
      assert assigns(:account).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Account.count' do
      create_account(:email => nil)
      assert assigns(:account).errors.on(:email)
      assert_response :success
    end
  end
  

  

  protected
    def create_account(options = {})
      post :create, :account => {  :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
