require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  
  def setup
    @controller = CommentsController.new 
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new 
  end
  
  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, :comment => valid_options_for_comment, :idea_id => ideas(:one)
    end

    assert_redirected_to idea_path(valid_options_for_comment[:idea_id])
  end

  test "should redirect to the idea when trying to create an invalid comment" do
    unless valid_options_for_comment.empty?
      assert_no_difference('Comment.count') do
        post :create, :comment => { }, :idea_id => ideas(:one)
      end
      
      assert_redirected_to idea_path(ideas(:one), :anchor => 'new_comment')
    end
  end

  test "should destroy comment" do
    idea = comments(:one).idea
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => comments(:one).id, :idea_id => idea.id
    end

    assert_redirected_to idea_path(idea)
  end
end
