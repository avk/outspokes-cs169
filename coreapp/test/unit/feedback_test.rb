require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test "feedback should be associated with a commenter" do
    feedback = create_feedback(:commenter => nil)
    assert !feedback.valid
  end
  
  test "feedback should be associated with a page" do
    feedback = create_feedback(:page => nil)
    assert !feedback.valid
  end
  
  test "feedback should have content" do
    feedback = create_feedback(:content => nil)
    assert !feedback.valid
  end
  
  test "feedback should not have blank content" do
    feedback = create_feedback(:content => '')
    assert !feedback.valid
  end

end
