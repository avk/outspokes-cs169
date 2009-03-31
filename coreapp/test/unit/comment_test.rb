require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "should create feedback" do
    assert_difference 'Comment.count' do
      feedback = create_private_comment
      assert !feedback.new_record?, "#{feedback.errors.full_messages.to_sentence}"
    end
  end
  
  test "should be associated with a commenter" do
    feedback = create_private_comment(:commenter => nil)
    assert !feedback.valid?
    # assert feedback.errors.on(:commenter_id), "allowing feedback to be saved without a commenter"
  end
      
  test "should be associated with a page" do
    feedback = create_private_comment(:page => nil)
    assert !feedback.valid?
  end
  
  test "should have content" do
    feedback = create_private_comment(:content => nil)
    assert !feedback.valid?
  end
  
  test "should not have blank content" do
    feedback = create_private_comment(:content => '')
    assert !feedback.valid?
  end
  
  test "should have a target" do
    feedback = create_private_comment(:target => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes for json" do
    feedback = create_private_comment
    json_atts = {
      "feedback_id" => feedback.id,
      "name" => feedback.commenter.email,
      "timestamp" => feedback.created_at.to_i,
      "content" => feedback.content,
      "target" => feedback.target
    }
    
    assert Comment.json_attribute_names.sort == json_atts.keys.sort
    feedback.json_attributes.each do |key, value|
      assert json_atts[key] == value
    end
  end
  
  test "can create public feedbacks without an account" do
    assert_difference "Comment.count" do
      f = Comment.create(valid_options_for_public_comment)
      assert_valid f
    end
  end
  
  test "can't create a public comment without a name" do
    assert_no_difference "Comment.count" do
      f = Comment.create(valid_options_for_public_comment.merge(:name => nil))
      assert !f.valid?
    end
  end
  
  test "generates proper json for public feedback" do
    f = Comment.create(valid_options_for_public_comment)
    assert_valid f
    json_atts = {
      "feedback_id" => f.id,
      "name" => f.name,
      "timestamp" => f.created_at.to_i,
      "content" => f.content,
      "target" => f.target
    }
    js = f.json_attributes.to_json
    json_obj = ActiveSupport::JSON::decode(js)
    json_atts.each do |key, val|
      assert json_obj[key] == val, "Feedback.#{key} should be #{val}. Instead: #{json_obj[key]}"
    end
      
  end
  
end
