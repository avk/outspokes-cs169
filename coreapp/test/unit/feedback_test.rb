require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase

  test 'feedbacks cannot be created' do
    assert_raises RuntimeError do
      f = Feedback.new
    end
  end
  
end

