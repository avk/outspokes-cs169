require 'test_helper'

class Widget::TagsControllerTest < ActionController::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # test "should be able to tag a feedback" do
  #   feedback = feedbacks(:one)
  #   old_tags = feedback.tag_list
  #   new_tag = 'RADLab'
  #   
  #   post :add_tag, :page_id => feedback.page_id, :id => feedback.id, :tag_list => new_tag
  #   
  #   feedback.reload
  #   new_tags = feedback.tag_list.to_a
  #   expected_tags = old_tags.to_a + [new_tag]
  #   assert new_tags == expected_tags, "expected: #{expected_tags.inspect} but got: #{new_tags.inspect}"
  #   
  #   assert_redirected_to page_path(feedback.page)
  # end
  # 
  # test "should be able to delete a feedback tag" do
  #   feedback = create_private_comment
  #   original_tags = "Funny, Silly, Happy, Sad"
  #   feedback.tag_list = original_tags
  #   feedback.save
  #   deleted_tag = "Sad"
  #   
  #   delete :delete_tag, :page_id => feedback.page_id, :id => feedback.id, :tag => "Sad"
  #   
  #   feedback.reload
  #   new_tags = feedback.tag_list.to_a
  #   expected_tags = original_tags.split(", ") - [deleted_tag]
  #   assert new_tags == expected_tags, "expected: #{expected_tags.inspect} but got: #{new_tags.inspect}"
  #   
  #   assert_redirected_to page_path(feedback.page)
  # end
end
