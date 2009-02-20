require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  test "should have an author" do
    comment = create_comment(:author => nil)
    assert !comment.valid?
  end

  test "should not allow a blank author" do
    comment = create_comment(:author => '')
    assert !comment.valid?
  end

  test "should not allow a non-alphanumeric string for the author" do
    comment = create_comment(:author => '@#$)(*&!#!)')
    assert !comment.valid?
  end
  
  test "should have an alphanumeric string for the author" do
    comment = create_comment(:author => 'Johny234')
    assert comment.valid?
  end
  
  test "should have a body" do
    comment = create_comment(:body => nil)
    assert !comment.valid?
  end
  
  test "should be associated with an idea" do
    comment = create_comment(:idea_id => nil)
    assert !comment.valid?
  end
  
  test "should be associated with a valid idea" do
    comment = create_comment(:idea => invalid_idea)
    assert !comment.valid?
  end
end
