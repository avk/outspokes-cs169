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

  test "should require login on GET edit" do
    get :edit, :id => commenters(:quentin).id
    assert_login_required
  end

  test "should require login on PUT update" do
    put :update, :id => commenters(:quentin).id, :account => { :email => 'quire@example.com',
      :password => 'foobara', :password_confirmation => 'foobar' }
    assert_login_required
  end

  test "should require login on GET dashboard" do
    get :dashboard, :id => commenters(:quentin).id
    assert_login_required
  end
  
  def test_should_update_account
    login_as :quentin
    oldemail = commenters(:quentin).email
    oldpass = commenters(:quentin).password
    newemail = 'quire@foo.com'
    newpass = 'foobar'
    assert_no_difference 'Account.count' do
      put :update, :id => commenters(:quentin).id, :account => { :email => newemail,
           :password => newpass, :password_confirmation => newpass }
      assert_response :redirect

      commenters(:quentin).reload

      assert commenters(:quentin).email != oldemail
      assert commenters(:quentin).email == newemail
      assert commenters(:quentin).crypted_password != commenters(:quentin).encrypt(oldpass)
      assert commenters(:quentin).crypted_password == commenters(:quentin).encrypt(newpass)
    end
  end
  
  def test_should_not_update_account_mismatched_passwords
    login_as :quentin
    assert_no_difference 'Account.count' do
      put :update, :id => commenters(:quentin).id, :account => { :email => 'quire@example.com',
           :password => 'foobara', :password_confirmation => 'foobar' }
      assert_template 'accounts/edit.html.erb'
    end
  end

  def test_should_update_account_preferred_notification
    login_as :quentin
    new_preferred_notification = '1'
    assert commenters(:quentin).preferred_deliver_notifications != new_preferred_notification, "change test data to be different"
    put :update, :id => commenters(:quentin).id, :account => {
      :preferred_deliver_notifications => new_preferred_notification
    }
    assert commenters(:quentin).preferred_deliver_notifications
  end

  test "should render reset_password.html.erb for GET reset-password" do
    get :reset_password
    assert_template 'accounts/reset_password.html.erb'
  end

  test "should warn if account can't be found by email" do
    put :reset_password, :email => 'untouchable@outspokes.com'
    assert_equal "Couldn't find an account with that email", flash[:warning]
  end
  
  # see also: test/unit/account_test.rb for reset_password!
  test "should reset password if email is found" do
    put :reset_password, :email => commenters(:quentin).email
    assert_equal "Check your email for the reset password", flash[:notice]
  end

  protected
    def create_account(options = {})
      post :create, :account => {  :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
