require File.dirname(__FILE__) + '/../test_helper'

class CommentersControllerTest < ActionController::TestCase

  def setup
    @invite = invites(:one)
    @url_token = @invite.url_token
    @commenter = @invite.commenter
  end

  test "should protect GET edit with url_token" do
    get :edit, :id => 1
    assert_login_required
  end

  test "should protect PUT update with url_token" do
    put :update, :id => 1
    assert_login_required
  end

  test "GET edit should find commenter to edit" do
    get :edit, :id => @commenter.id, :url_token => @url_token
    assert assigns(:commenter)
  end

  test "PUT update should update preferences" do
    old_email = @commenter.email
    put :update, :id => @commenter.id, :url_token => @url_token,
      :commenter => { :email => 'test@foo.com' }
    assert_not_equal old_email, @commenter.reload.email
  end
end
