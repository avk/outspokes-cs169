require 'test_helper'

class MailerTest < ActionMailer::TestCase

  test 'Should send an email to the correct address' do
	person = commenters(:one)
    page = pages(:one)
	invite = create_invite

    mail = Mailer.create_commenter_invite(person, page)

    assert_equal mail.to[0], person.email
  end

end
