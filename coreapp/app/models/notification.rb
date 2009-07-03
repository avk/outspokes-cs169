# Notifications are queued aggregations of feedbacks and opinions
# relating to a site that are delivered to admins and commenters at a
# later time.  There is one active Notification for a site at a given
# time.  Feedbacks, opinions, and other reactions will record a new
# message in the current notification.  When cron decides it's time to
# deliver notifications, all pending notifications will 'deliver'
# itself and update it's status.
class Notification < ActiveRecord::Base
  include AASM

  belongs_to :site
  has_and_belongs_to_many :feedbacks
  has_and_belongs_to_many :opinions

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
  
  # add a Feedback or an Opinion into the current Notification
  def self.put(feedback_or_opinion)
    site = case feedback_or_opinion
           when Feedback
             feedback_or_opinion.page.site
           when Opinion
             feedback_or_opinion.feedback.page.site
           else
             raise ArgumentError.new("Notification doesn't know what to do with a #{feedback_or_opinion.class.to_s}")
           end

    notification = pending.find_by_site_id(site) || Notification.new(:site => site)
    notification.put(feedback_or_opinion)
    notification.save
    notification
  end

  # add a Feedback or an Opinion into this Notification.
  def put(feedback_or_opinion)
    case feedback_or_opinion
    when Feedback
      self.feedbacks << feedback_or_opinion
    when Opinion
      self.opinions << feedback_or_opinion
    else
      raise ArgumentError.new("Notification doesn't know what to do with a #{feedback_or_opinion.class.to_s}")
    end
  end

  protected

  # determines what recipients to deliver the notification to based on
  # preferences and delivers this notification
  # 
  # Do not call this method directly.  See event deliver!
  def do_delivery
    do_notify = Proc.new { |m| m.preferred_deliver_notifications }
    accounts   = [ site.account ].select(&do_notify)
    commenters = site.pages.collect(&:commenters).flatten.uniq.select(&do_notify)

    begin
      Mailer.deliver_notification(accounts + commenters, self)
    rescue Exception => e
      HoptoadNotifier.notify(e)
      return false  # on failure
    end
    true
  end
end
