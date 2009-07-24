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

  def notification(commenter_or_account, notification)
    setup_email
    recipients   commenter_or_account.email
    subject      "Recent feedback left on your site"
    if commenter_or_account.is_a?(Account)
      url = edit_account_url(commenter_or_account)
    else
      url_token = commenter_or_account.invites.find_by_page_id(notification.site.home_page.id).url_token
      url = edit_commenter_url(commenter_or_account, :url_token => url_token)
    end

    body :notification => notification, :url => url
  end

  protected

  def setup_email
    from         CONFIG.emails.no_reply
    sent_on      Time.now
    content_type "text/html"    
  end

end
