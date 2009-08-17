# Notifications are queued aggregations of feedbacks relating to a
# site that are delivered to admins and commenters at a later time.
# There is one active Notification for a site at a given time.
# Feedbacks, and potentially other reactions will record a new message
# in the current notification.  When cron decides it's time to deliver
# notifications, all pending notifications will 'deliver' itself and
# update it's status.
class Notification < ActiveRecord::Base
  include AASM

  belongs_to :site
  has_and_belongs_to_many :feedbacks, :include => [ :commenter, :page ]

  # TODO: concept of successfully deliveries for when we retry.
  # has_and_belongs_to_many :delivered_recipients, :table_name => 'commenters_notifications'
  # self.delivered_recipients << recipient

  # (commenters - delivered_recipients).each
  # (accounts - delivered_recipients).each

  # on enter 'delivered' state, clear out delivered_recipients? (nah) 

  validates_presence_of :site

  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :delivered
  aasm_state :errored

  aasm_event :deliver do
    transitions :to => :delivered,
      :from  => [ :pending, :errored ],
      :guard => :do_delivery

    transitions :to => :errored,
      :from => [ :pending, :errored ]
  end
  
  # add a Feedback into the current Notification for it's Site
  def self.put(feedback)
    site = feedback.page.site

    notification = pending.find_by_site_id(site) || Notification.new(:site => site)
    notification.feedbacks << feedback
    notification.save!
    notification
  end

  # An administrator's feedback is all feedbacks except his own
  def admin_feedbacks
    feedbacks.not_by(site.account)
  end

  # A commenter's feedback is all public feedbacks except his own,
  # and private feedbacks in reply to his own.
  #
  # OPTIMIZE: figuring out private replies is bound by the number of
  # private replies stored in this notification, which should be low
  # if delivered hourly.
  def commenter_feedbacks(commenter)
    feedbacks.public.not_by(commenter) + \
    feedbacks.private.select do |f|
      is_reply = false
      parent = f
      while parent = parent.parent
        if parent.commenter == commenter
          break is_reply = true
        end
      end
      is_reply
    end
  end

  # Takes an array of feedback objects and returns a hash keyed by
  # page objects, and value hash keyed by :comments, and :user_styles
  #
  #  pageObj => {
  #   :comments    => [ comment1,...,commentN ],
  #   :user_styles => [ style1,...,styleN ]
  #  }
  #
  def self.feedbacks_by_page(feedbacks_list)
    ret_hash = {}
    feedbacks_list.each do |f|
      ret_hash[f.page] ||= { :comments => [], :user_styles => [] }
      ret_hash[f.page][f.class.name.underscore.pluralize.to_sym] << f
    end
    ret_hash
  end

  def pages
    feedbacks.map(&:page).flatten.uniq
  end

  def comments
    feedbacks.select { |f| f.is_a? Comment }
  end

  def user_styles
    feedbacks.select { |f| f.is_a? UserStyle }
  end

  protected

  # determines what recipients to deliver the notification to based on
  # preferences and delivers this notification
  # 
  # Do not call this method directly.  This is the guard for the
  # 'deliver' event.  If this method returns true, then the
  # notification goes into 'delivered' state.  If it returns false,
  # then the notification goes into 'errored' state.
  def do_delivery
    do_notify = Proc.new do |m|
      m.preferred_deliver_notifications(site.id)
    end

    # how to mark recipients as successfully completed?
    accounts   = [ site.account ].select(&do_notify)
    commenters = (site.commenters - accounts).select(&do_notify)

    all_delivered = true

    accounts.each do |recipient|
      feedbacks = Notification.feedbacks_by_page(admin_feedbacks)
      next if feedbacks.empty?
      all_delivered = all_delivered && HoptoadNotifier.fail_silently do
        Mailer.deliver_account_notification(recipient, site, feedbacks)
      end
    end

    commenters.each do |recipient|
      feedbacks = Notification.feedbacks_by_page(commenter_feedbacks(recipient))
      next if feedbacks.empty?
      all_delivered = all_delivered && HoptoadNotifier.fail_silently do
        Mailer.deliver_commenter_notification(recipient, site, feedbacks)
      end
    end

    all_delivered
  end
end
