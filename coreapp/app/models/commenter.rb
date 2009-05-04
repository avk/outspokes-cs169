class Commenter < ActiveRecord::Base

  has_many :invites, :dependent => :destroy
  has_many :pages, :through => :invites
  has_many :feedbacks, :dependent => :destroy
  has_many :opinions, :dependent => :destroy

  #stolen from the restful_authentication plugin
  @@email_name_regex  = '[\w\.%\+\-]+'.freeze
  @@domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  @@domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  @@email_regex       = /\A#{@@email_name_regex}@#{@@domain_head_regex}#{@@domain_tld_regex}\z/i
  @@bad_email_message = "should look like an email address.".freeze

  validates_presence_of :email, :allow_blank => false
  validates_format_of :email, :with => @@email_regex  
  validates_uniqueness_of :email

  def self.parse_email_addresses(emails)
    separated = emails.split(',')
    separated.map! {|str| str.strip}
    
    legal, illegal = [], []
    separated.each do |email|
      if email.match @@email_regex
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
  
  def truncated_email
    return (self.email.length >= 20) ? self.email.first(20) + '...' : self.email
  end
end
