require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  test "should create feedback" do
    assert_difference('Feedback.count') do
      post :create, :feedback => valid_options_for_feedback
      puts assigns(:feedback).errors.full_messages.to_sentence
    end

    assert_redirected_to page_path(valid_options_for_feedback[:page_id])
  end

  test "should go back to page when trying to create an invalid feedback" do
    unless valid_options_for_feedback.empty?
      assert_no_difference('Feedback.count') do
        post :create, :feedback => { :page_id => pages(:one).id, :commenter_id => commenters(:one).id }
      end

      assert_redirected_to page_path(pages(:one))
    end
  end

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
