class Mailer < ActionMailer::Base

  def commenter_invite(invite)
    from         "outspokes-no-reply@outspokes.com"
    recipients   invite.commenter.email
    sent_on      Time.now
    content_type "text/html"

    url = invite.page.url + '?url_token=' + invite.url_token
    page = invite.page
    site = page.site

    name = (!site.nil?) ? site.name : URI.parse(page.url).host
    account_email = (!site.nil?) ? site.account.email : page.account.email
    subject      account_email + " has invited you to give feedback via Outspokes"
    body         :url => url, :name => name, :account_email => account_email 
  end  

end
