require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test "should create feedback" do
    assert_difference 'Feedback.count' do
      feedback = create_feedback
      assert !feedback.new_record?, "#{feedback.errors.full_messages.to_sentence}"
    end
  end
  
  test "should be associated with a commenter" do
    feedback = create_feedback(:commenter => nil)
    assert !feedback.valid?
    # assert feedback.errors.on(:commenter_id), "allowing feedback to be saved without a commenter"
  end
      
  test "should be associated with a page" do
    feedback = create_feedback(:page => nil)
    assert !feedback.valid?
  end
  
  test "should have content" do
    feedback = create_feedback(:content => nil)
    assert !feedback.valid?
  end
  
  test "should not have blank content" do
    feedback = create_feedback(:content => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes as public" do
    public_atts = %w(created_at updated_at content)
    assert Feedback.public_attribute_names.sort == public_atts.sort
    
    feedback = create_feedback
    assert feedback.public_attributes.keys.sort == public_atts.sort
  end
end
