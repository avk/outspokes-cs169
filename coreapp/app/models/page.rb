class Page < ActiveRecord::Base

  belongs_to :site

  has_many :invites, :dependent => :destroy, :validate => false
  has_many :commenters, :through => :invites  # reader doesn't include 'account'
  has_many :feedbacks, :dependent => :destroy, :validate => false
  has_many :comments, :dependent => :destroy
  has_many :user_styles, :dependent => :destroy

  delegate :account, :to => :site

  before_validation :create_invite_for_account
  
  validates_presence_of :site
  validates_presence_of :url
  validate :validate_format_of_url
 
  validates_uniqueness_of :url, :scope => :site_id, :unless => Proc.new { |page| page.site_id.blank? } # FIXME: singleton pages relic? site_id should never be blank
  validates_length_of :invites, :minimum => 1
  
  validate :is_child_of_site
  validate :page_url_can_not_have_trailing_slashes
  
  
  def url=(url)
    if self.url and !self.site_id.blank? # FIXME: singleton pages relic? site_id should never be blank
      raise "Cannot set url for a page attached to a site"
    else
      super url
    end
  end

  def commenter_url(commenter_or_account)
    url.sub(/\/$/i, '') + '#url_token=' + invites.find_by_commenter_id(commenter_or_account).url_token
  end
  
  def admin_url
    commenter_url(site.account) + '&admin=true'
  end

  def commenters_without_account
    commenters - [ account ]
  end

  protected

  def create_invite_for_account
    if invites.empty?
      self.invites.build(:commenter => site.account)
    end
    true
  end

  def validate_format_of_url
    begin
      scheme = URI.parse(url).scheme
      unless ['http', 'https'].include?(scheme)
        errors.add(:url, "has an invalid URL scheme: #{scheme}") 
      end
    rescue URI::InvalidURIError
      errors.add(:url, "is invalid")
    end    
  end

  # Verify that this url has the same domain as the associated Site's home_page's url
  def is_child_of_site
    return true if url.nil? # FIXME: I think this is a bug
    return true if site.home_page === self # I am the homepage

    if errors.on(:url).blank?
      unless URI.same_domain?(url, site.url)
        errors.add(:url, "This page's url has a different domain (#{URI.base_domain(url)}) than the site's (#{URI.base_domain(site.url)})")
      end
    end
  end
  
  def page_url_can_not_have_trailing_slashes
    if(url)
      errors.add(:url, "cannot have trailing slashes") unless url[url.length-1, 1]!='/'
    end
  end
end
