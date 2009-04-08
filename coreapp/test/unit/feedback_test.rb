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
  
  test "should have a target" do
    feedback = create_feedback(:target => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes for json" do
    feedback = create_feedback
    json_atts = {
      "feedback_id" => feedback.id,
      "name" => feedback.commenter.email,
      "timestamp" => feedback.created_at.to_i,
      "content" => feedback.content,
      "target" => feedback.target
    }
    
    assert Feedback.json_attribute_names.sort == json_atts.keys.sort
    feedback.json_attributes.each do |key, value|
      assert json_atts[key] == value
    end
  end

  test "should return score of length of matching search term if it matches" do
    feedback = create_feedback(:content => 'Bob is my friend')
    assert feedback.search_score("my") == 2
  end
  
  test "should return score of 0 if search term doesn't match" do
    feedback = create_feedback(:content => 'Bob is my friend')
    assert feedback.search_score("whale") == 0
  end
  
  test "should not be case sensitive when searching" do
    feedback = create_feedback(:content => 'Bob is my friend')
    assert feedback.search_score("MY") == 2
  end
  
  test "should return score of 50 if author contains search term" do
    feedback = create_feedback(:content => 'Bob is my friend', :commenter => 1)
    assert feedback.search_score("MY") == 2
  end
end

