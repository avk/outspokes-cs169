require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "should create valid notification" do
    assert_difference "Notification.count" do
      notification = create_notification
      assert !notification.new_record?, notification.errors.full_messages.to_sentence
    end
  end

  test "should require site" do
    assert_no_difference "Notification.count" do
      notification = create_notification(:site => nil)
      assert notification.errors.on(:site), "Allowing nil site"
    end
  end

  test "initial state should be pending" do
    assert_equal 'pending', create_notification.aasm_state
  end

  test "put should find an existing pending notification for a site" do
    feedback     = feedbacks(:notification)
    notification = create_notification(:site => feedback.page.site)

    assert_no_difference "Notification.count" do
      assert_difference "notification.feedbacks.size", 1 do
        notification = Notification.put(feedback)
      end
    end
  end

  test "put should create a new notification if one doesn't exist" do
    assert_difference "Notification.count", 1 do
      Notification.put(feedbacks(:one))
      assert_equal 1, Notification.first.feedbacks.size
    end
  end

#  test "deliver should send email to admins and commenters" do
#    notification = create_notification
#    assert_difference "ActionMailer::Base.deliveries.size", 2 do
#      notification.deliver!
#    end
#    assert_equal 'delivered', notification.aasm_state
#  end

  test "feedbacks_by_page should sort feedbacks by page, and feedback type" do
    comment = feedbacks(:notification)
    user_style = feedbacks(:user_style1)

    notification = create_notification(:feedbacks => [comment, user_style])
    assert [ comment ], notification.feedbacks_by_page[comment.page][:comments]
    assert [ user_style ], notification.feedbacks_by_page[user_style.page][:user_styles]
  end

  # don't know how to simulate an error in Test::Unit
  # test "deliver! should go to errored state on error"
end
