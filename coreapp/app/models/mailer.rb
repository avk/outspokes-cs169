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

  def account_notification(account, site, feedbacks)
    setup_email
    recipients   account.email
    subject      "Recent feedback left on your site: #{notification.site.name}"

    body :account => account, :site => site, :feedbacks => feedbacks
  end

  def commenter_notification(commenter, notification)
    setup_email
    recipients   commenter.email
    subject      "Recent feedback on #{notification.site.name}"
    
    body :commenter => commenter, :site => site, :feedbacks => feedbacks
  end

  protected

  def setup_email
    from         CONFIG.emails.no_reply
    sent_on      Time.now
    content_type "text/html"    
  end

end
