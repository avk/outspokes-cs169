require 'test_helper'

class IdeaTest < ActiveSupport::TestCase

  test "an idea must have a name" do
    idea = create_idea(:name => nil)
    assert !idea.valid?, "creating an idea w/o a name"
  end
  
  test "an idea must have a body" do
    idea = create_idea(:body => nil)
    assert !idea.valid?, "creating an idea w/o a body"
  end

end
