require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < ActionMailer::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  def test_should_send_correct_email_to_correct_address
    invite = create_invite
    Mailer.deliver_commenter_invite(invite)
    mail = ActionMailer::Base.deliveries[0]
    body = mail.body
    url = invite.page.url + '?url_token=' + invite.url_token
    name = invite.page.site.name
    account_email = invite.inviter.email

    assert body.scan(account_email.to_s + " has invited you to")
    assert body.scan("give feedback on " + name.to_s)
    assert body.scan(url)
    assert mail.to[0] == invite.commenter.email.to_s
    assert mail.from[0] == "outspokes-no-reply@outspokes.com"
    assert mail.subject == account_email.to_s + " has invited you to give feedback via Outspokes"
  end

  test "notification to account should have an opt-out link" do
    account = commenters(:quentin)
    invite = account.invites.first
    site = invite.page.site
    
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      Mailer.deliver_notification(account, create_notification(:site => site))
    end
    mail = ActionMailer::Base.deliveries.first
    # assert mail.body.include?("edit?url_token=wendy_token")
    assert_match /accounts\/.*\/edit/, mail.body
  end

  test "notification to commenter should have an opt-out link" do
    commenter = commenters(:wendy)
    invite = commenter.invites.first
    site = invite.page.site
    
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      Mailer.deliver_notification(commenter, create_notification(:site => site))
    end
    mail = ActionMailer::Base.deliveries.first
    # assert mail.body.include?(edit_commenter_url(commenter, :url_token => invite.url_token))
    assert_match /commenters\/.*\/edit\?url_token=wendy_token/, mail.body
  end

end
