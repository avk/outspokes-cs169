require 'test_helper'

class EmailReqsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:email_reqs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create email_req" do
    assert_difference('EmailReq.count') do
      post :create, :email_req => { }
    end

    assert_redirected_to email_req_path(assigns(:email_req))
  end

  test "should show email_req" do
    get :show, :id => email_reqs(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => email_reqs(:one).id
    assert_response :success
  end

  test "should update email_req" do
    put :update, :id => email_reqs(:one).id, :email_req => { }
    assert_redirected_to email_req_path(assigns(:email_req))
  end

  test "should destroy email_req" do
    assert_difference('EmailReq.count', -1) do
      delete :destroy, :id => email_reqs(:one).id
    end

    assert_redirected_to email_reqs_path
  end
end
