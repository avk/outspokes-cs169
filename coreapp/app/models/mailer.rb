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

    site_name = site.name
    who = site.account.name
    subject      who + " has invited you to give feedback via Outspokes"
    body         :url => url, :site_name => site_name, :who => who
  end

  def account_signup(account)
    setup_email
    from         CONFIG.emails.support
    recipients   account.email
    subject      "Welcome to Outspokes!"
    body         :admin_url => dashboard_account_url(account), :tour_url => root_path
  end

  def notification(to_users, notification)
    setup_email
    recipients   Array(to_users).map(&:email)
    subject      "Recent feedback left on your site"
    body         :notification => notification
  end
  
  def account_deletion(account, reason)
    setup_email
    recipients  CONFIG.emails.feedback
    subject     "#{account.email} has deleted his or her account"
    body        :reason => reason
  end
  

  def reset_password(account)
    setup_email
    recipients   account.email
    subject      "Reset password request"
    body         :account => account
  end

  protected

  def setup_email
    from         CONFIG.emails.no_reply
    sent_on      Time.now
    content_type "text/html"    
  end

end
