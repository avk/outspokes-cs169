class Commenter < ActiveRecord::Base

  has_many :invites, :dependent => :destroy, :validate => false
  has_many :pages, :through => :invites # pages invited to, not pages commented on
  has_many :feedbacks, :dependent => :destroy, :validate => false
  has_many :opinions, :dependent => :destroy, :validate => false
  has_many :comments, :dependent => :destroy
  has_many :user_styles, :dependent => :destroy

  validates_presence_of :email, :allow_blank => false
  validates_length_of   :email, :within => 6..100 #r@a.wk
  validates_format_of   :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message

  # FIXME: efficient way to check email is unique across Sites.
  validates_uniqueness_of :email

  # pluginaweek/preferences
  preference :deliver_notifications, :default => true

  def self.parse_email_addresses(emails)
    separated = emails.split(',')
    separated.map! {|str| str.strip}
    
    legal, illegal = [], []
    separated.each do |email|
      if email.match Authentication.email_regex
        legal << email
      else
        illegal << email
      end
    end
    
    {:legal => legal, :illegal => illegal}
  end

  def agree(feedback_id)
    opinions.create(:feedback_id => feedback_id, :agreed => true)
  end
  
  def disagree(feedback_id)
    opinions.create(:feedback_id => feedback_id, :agreed => false)
  end
  
  def agreed_with
    opinions.find_all_by_agreed(true)
  end
  
  def disagreed_with
    opinions.find_all_by_agreed(false)
  end

  def opinion_of(feedback_id)
    return 'mine' if feedbacks.map(&:id).include?(feedback_id)
    
    opinions.each do |op|
      if op.feedback_id == feedback_id
        return (op.agreed?) ? 'agreed' : 'disagreed' 
      end
    end
    return nil
  end
  
  def feedbacks_for_site(site_id)
    begin
      site = Site.find(site_id)
      page_ids = site.pages.map(&:id)
      self.feedbacks.select {|f| page_ids.include?(f.page_id)}
    rescue ActiveRecord::RecordNotFound => e
      []
    end
  end
  
  def feedbacks_for_page(page_id)
    self.feedbacks.select {|f| f.page_id == page_id }
  end
  
  def commented_pages(*args)
    if(args.length == 1)
      Feedback.find(:all, :joins =>:page, :conditions =>  ["pages.site_id = ? AND feedbacks.commenter_id = ?", args[0], self], :group => "feedbacks.page_id").map {|f| f.page }
    else
      self.feedbacks.find(:all, :include => :page, :group => :page_id).map {|f| f.page }  
    end
  end  
  
  def truncated_email
    shortened_email = self.email.split('@').first
    return (shortened_email.length >= 15) ? shortened_email.first(15) + '...' : shortened_email
  end
  
  def short_email
    self.email.split('@').first
  end
  
end
