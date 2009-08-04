class Mailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = CONFIG.domain
  layout 'email'

  def commenter_invite(invite)
    setup_email
    recipients   invite.commenter.email
    reply_to     invite.inviter.email

    url = invite.page.url + '#url_token=' + invite.url_token
    page = invite.page
    site = page.site

    name = site.name
    account_email = site.account.email
    subject      account_email + " has invited you to give feedback via Outspokes"
    body         :url => url, :name => name, :account_email => account_email 
  end

  def account_signup(account)
    setup_email
    from         CONFIG.emails.support
    recipients   account.email
    subject      "Welcome to Outspokes!"
    body         :admin_url => dashboard_account_url(account), :tour_url => root_path
  end

  def account_notification(account, notification)
    setup_email
    recipients   account.email
    subject      "Recent feedback left on your site"

    body :notification => notification, :account => account
  end

  def commenter_notification(commenter, notification)
    setup_email
    recipients   commenter.email
    subject      "Recent feedback on #{notification.site.url}"
    
    body :notification => notification, :commenter => commenter
  end

  protected

  def setup_email
    from         CONFIG.emails.no_reply
    sent_on      Time.now
    content_type "text/html"    
  end

end
