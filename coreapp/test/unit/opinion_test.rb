require File.dirname(__FILE__) + '/../test_helper'

class OpinionTest < ActiveSupport::TestCase

  test 'should be able to create an opinion' do
    assert_difference "Opinion.count", 1 do
      opinion = create_opinion
      assert !opinion.new_record?, "#{opinion.errors.full_messages.to_sentence}"
    end
  end
  
  test 'should have a feedback' do
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:feedback => nil)
      assert opinion.errors.on(:feedback_id)
    end
  end
  
  test 'should have a valid feedback' do
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:feedback => Comment.create(invalid_options_for_comment))
      assert opinion.errors.on(:feedback)
    end
  end
  
  test 'should have a commenter' do
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:commenter => nil)
      assert opinion.errors.on(:commenter_id)
    end
  end
  
  test 'should have a valid commenter' do
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:commenter => Commenter.create(invalid_options_for_commenters))
      assert opinion.errors.on(:commenter)
    end
  end
  
  test 'should not allow one commenter to have more than one opinion on the same feedback' do
    assert_difference "Opinion.count", 1 do
      opinion = create_opinion
      assert !opinion.new_record?
      opinion2 = create_opinion
      assert opinion2.errors.on(:feedback_id)
    end
  end
  
  test 'should require a commenter to take a position' do
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:agreed => nil)
      assert opinion.errors.on(:agreed)
    end
  end
  
  test 'should allow agreeing' do
    assert_difference "Opinion.count", 1 do
      opinion = create_opinion(:agreed => true)
      assert !opinion.new_record?
    end
  end
  
  test 'should allow disagreeing' do
    assert_difference "Opinion.count", 1 do
      opinion = create_opinion(:agreed => false)
      assert !opinion.new_record?
    end
  end
  
  test 'should not allow opinions on your own feedback' do
    commenter = create_commenter
    feedback = create_private_comment(:commenter => commenter)
    assert_no_difference "Opinion.count" do
      opinion = create_opinion(:commenter => commenter, :feedback => feedback)
      assert opinion.errors.on_base == "You cannot agree or disagree with your own feedback."
    end
  end
end
