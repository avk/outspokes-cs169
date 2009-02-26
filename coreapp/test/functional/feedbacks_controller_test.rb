require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:feedbacks)
  # end
  # 
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should create feedback" do
    assert_difference('Feedback.count') do
      post :create, :feedback => valid_options_for_feedback
    end

    assert_redirected_to feedback_path(assigns(:feedback))
  end

  # test "should show feedback" do
  #   get :show, :id => feedbacks(:one).id
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, :id => feedbacks(:one).id
  #   assert_response :success
  # end
  # 
  # test "should update feedback" do
  #   put :update, :id => feedbacks(:one).id, :feedback => { }
  #   assert_redirected_to feedback_path(assigns(:feedback))
  # end

  test "should destroy feedback" do
    assert_difference('Feedback.count', -1) do
      delete :destroy, :id => feedbacks(:one).id
    end

    assert_redirected_to feedbacks_path
  end
end
