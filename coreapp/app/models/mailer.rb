class Mailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = 'beta.outspokes.com'

  def commenter_invite(invite)
    setup_email
    recipients   invite.commenter.email
    reply_to     invite.inviter.email

    url = invite.page.url + '#url_token=' + invite.url_token
    page = invite.page
    site = page.site

    name = (!site.nil?) ? site.name : URI.parse(page.url).host
    account_email = (!site.nil?) ? site.account.email : page.account.email
    subject      account_email + " has invited you to give feedback via Outspokes"
    body         :url => url, :name => name, :account_email => account_email 
  end

  def account_signup(account)
    setup_email
    from         "support@outspokes.com"
    recipients   account.email
    subject      "Welcome to Outspokes!"
    body         :admin_url => dashboard_account_url(account), :tour_url => faq_url
  end

  protected

  def setup_email
    from         "outspokes-no-reply@outspokes.com"
    sent_on      Time.now
    content_type "text/html"    
  end

end
