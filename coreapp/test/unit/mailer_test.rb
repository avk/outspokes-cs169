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
    account_name = invite.inviter.name

    assert body.scan(account_name.to_s + " has invited you to")
    assert body.scan("give feedback on " + name.to_s)
    assert body.scan(url)
    assert mail.to[0] == invite.commenter.email.to_s
    assert mail.from[0] == "outspokes-no-reply@outspokes.com"
    assert mail.subject == account_name.to_s + " has invited you to give feedback via Outspokes"
  end

end
