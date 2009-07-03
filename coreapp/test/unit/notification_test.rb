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

  test "put should raise error when argument is not feedback or opinion" do
    assert_raises ArgumentError do
      Notification.put("BAD_ARGUMENT")
    end
  end

  test "put should find an existing pending notification for a site" do
    notification = create_notification
    site = notification.site
    feedback = feedbacks(:notification)
    assert_no_difference "Notification.count" do
      Notification.put(feedback)
      assert_equal 1, Notification.first.feedbacks.size
    end
  end

  test "put should create a new notification if one doesn't exist" do
    assert_difference "Notification.count", 1 do
      Notification.put(feedbacks(:one))
      assert_equal 1, Notification.first.feedbacks.size
    end
  end

  test "put should add feedback" do
    notification = create_notification
    assert_difference "notification.feedbacks.size", 1 do
      notification.put(feedbacks(:one))
    end
  end

  test "put should add opinion" do
    notification = create_notification
    assert_difference "notification.opinions.size", 1 do
      notification.put(opinions(:popular1_agreed_1))
    end
  end

  test "deliver! should send email to admins and commenters" do
    notification = create_notification
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      notification.deliver!
    end
    assert_equal 'delivered', notification.aasm_state
  end

  # don't know how to simulate an error in Test::Unit
  # test "deliver! should go to errored state on error"
end
