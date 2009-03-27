require 'test_helper'

class SiteTest < ActiveSupport::TestCase


  test 'feedbacks cannot be created' do
    assert_raises RuntimeError do
      f = Feedback.new
    end
  end
  
end