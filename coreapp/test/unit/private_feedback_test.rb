require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test "should create feedback" do
    assert_difference 'Feedback.count' do
      feedback = create_private_feedback
      assert !feedback.new_record?, "#{feedback.errors.full_messages.to_sentence}"
    end
  end
  
  test "should be associated with a commenter" do
    feedback = create_private_feedback(:commenter => nil)
    assert !feedback.valid?
    # assert feedback.errors.on(:commenter_id), "allowing feedback to be saved without a commenter"
  end
      
  test "should be associated with a page" do
    feedback = create_private_feedback(:page => nil)
    assert !feedback.valid?
  end
  
  test "should have content" do
    feedback = create_private_feedback(:content => nil)
    assert !feedback.valid?
  end
  
  test "should not have blank content" do
    feedback = create_private_feedback(:content => '')
    assert !feedback.valid?
  end
  
  test "should have a target" do
    feedback = create_private_feedback(:target => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes for json" do
    feedback = create_private_feedback
    json_atts = {
      "feedback_id" => feedback.id,
      "name" => feedback.commenter.email,
      "timestamp" => feedback.created_at.to_i,
      "content" => feedback.content,
      "target" => feedback.target
    }
    
    assert PrivateFeedback.json_attribute_names.sort == json_atts.keys.sort
    feedback.json_attributes.each do |key, value|
      assert json_atts[key] == value
    end
  end
  
end
