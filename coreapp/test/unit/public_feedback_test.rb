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
      f = PublicFeedback.create(:page => Page.find(:first), :content => "lulz", :target => "html")
      assert !f.valid?
    end
  end
  
end
