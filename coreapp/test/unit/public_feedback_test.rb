require 'test_helper'

class PublicFeedbackTest < ActiveSupport::TestCase
  
  test "can create public feedbacks without an account" do
    assert_difference "PublicFeedback.count" do
      f = PublicFeedback.create(:page => Page.find(:first), :name => "Joe", :content => "lulz", :target => "html")
      assert_valid f
    end
  end
  
  test "can't create a public comment without a name" do
    assert_no_difference "PublicFeedback.count" do
      f = PublicFeedback.create(valid_options_for_private_feedback)
      assert !f.valid?
    end
  end
  
  test "generates proper json for public feedback" do
    f = PublicFeedback.create(:page => Page.find(:first), :name => "Paul", :content => "lulz", :target => "html")
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
