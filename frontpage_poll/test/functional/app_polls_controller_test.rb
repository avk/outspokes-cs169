require 'test_helper'

class AppPollsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_polls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_poll" do
    assert_difference('AppPoll.count') do
      post :create, :app_poll => { }
    end

    assert_redirected_to app_poll_path(assigns(:app_poll))
  end

  test "should show app_poll" do
    get :show, :id => app_polls(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => app_polls(:one).id
    assert_response :success
  end

  test "should update app_poll" do
    put :update, :id => app_polls(:one).id, :app_poll => { }
    assert_redirected_to app_poll_path(assigns(:app_poll))
  end

  test "should destroy app_poll" do
    assert_difference('AppPoll.count', -1) do
      delete :destroy, :id => app_polls(:one).id
    end

    assert_redirected_to app_polls_path
  end
end
