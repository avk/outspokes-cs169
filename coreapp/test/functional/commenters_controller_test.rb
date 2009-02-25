require 'test_helper'

class CommentersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:commenters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create commenter" do
    assert_difference('Commenter.count') do
      post :create, :commenter => valid_options_for_commenters  
    end

    assert_redirected_to commenter_path(assigns(:commenter))
  end

  test "should show commenter" do
    get :show, :id => commenters(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => commenters(:one).id
    assert_response :success
  end

  test "should update commenter" do
    put :update, :id => commenters(:one).id, :commenter => valid_options_for_commenters
    assert_redirected_to commenter_path(assigns(:commenter))
  end

  test "should destroy commenter" do
    assert_difference('Commenter.count', -1) do
      delete :destroy, :id => commenters(:one).id
    end

    assert_redirected_to commenters_path
  end
end
