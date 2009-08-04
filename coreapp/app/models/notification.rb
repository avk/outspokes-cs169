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
    notification.save
    notification
  end

  # returns a hash keyed by page objects, and value hash keyed by
  # :comments, and :user_styles
  #
  #  pageObj => {
  #   :comments    => [ comment1,...,commentN ],
  #   :user_styles => [ style1,...,styleN ]
  #  }
  #
  # optional arguments
  #  :ignore_commenter - filter out feedbacks left by a given commenter.
  #  :ignore_private   - include only public feedbacks if true, all feedbacks otherwise
  def feedbacks_by_page(options = {})
    options.assert_valid_keys(:ignore_commenter, :ignore_private)
    options.reverse_merge!(:ignore_private => true)

    conditions = ""
    if options[:ignore_commenter]
      conditions = ["feedbacks.commenter_id != ?", options[:ignore_commenter].id]
    end
    scoped_feedbacks = (options[:ignore_private] ? feedbacks.public : feedbacks).all(:conditions => conditions)

    returning({}) do |h|
      scoped_feedbacks.each do |feedback|
        h[feedback.page] ||= { :comments => [], :user_styles => [] }
        h[feedback.page][feedback.class.name.underscore.pluralize.to_sym] << feedback
      end
    end
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
  # Do not call this method directly.  See event deliver!
  def do_delivery
    do_notify = Proc.new do |m|
      m.preferred_deliver_notifications(site.id)
    end

    accounts   = [ site.account ].select(&do_notify)
    commenters = (site.commenters.all - [ site.account ]).select(&do_notify)

    all_success = true

    accounts.each do |recipient|
      all_success = all_success && HoptoadNotifier.fail_silently do
        Mailer.deliver_account_notification(recipient, self)
      end
    end

    commenters.each do |recipient|
      all_success = all_success && HoptoadNotifier.fail_silently do
        Mailer.deliver_commenter_notification(recipient, self)
      end
    end

    all_success
  end
end
