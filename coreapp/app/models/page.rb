class Page < ActiveRecord::Base

  belongs_to :site

  has_many :invites, :dependent => :destroy, :validate => false
  has_many :commenters, :through => :invites  #, :conditions => "type != 'Account'"
  has_many :feedbacks, :dependent => :destroy, :validate => false
  has_many :comments, :dependent => :destroy
  has_many :user_styles, :dependent => :destroy

  delegate :account, :to => :site

  before_validation :create_invite_for_account
  
  validates_presence_of :site
  validates_presence_of :url
  validate :validate_format_of_url
 
  validates_uniqueness_of :url, :scope => :site_id, :unless => Proc.new { |page| page.site_id.blank? }
  validates_length_of :invites, :minimum => 1
  
  validate :is_child_of_site
  validate :page_url_can_not_have_trailing_slashes
  
  
  def url=(url)
    if self.url and !self.site_id.blank?
      raise "Cannot set url for a page attached to a site"
    else
      super url
    end
  end

  def commenter_url(commenter_or_account)
    url.sub(/\/$/i, '') + '#url_token=' + invites.find_by_commenter_id(commenter_or_account).url_token
  end

  # converts "http://www.apple.com/itunes/" to "http://www.apple.com"
  def self.domainize(url)
    base_domain = /^(https?:\/\/[\w\d\-\.]*)/i
    (url.match base_domain) ? $1 : nil
  end

  def admin_url
    commenter_url(site.account) + '&admin=true'
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
    return true if url.nil?
    return true if site.home_page === self # I am the homepage

    if errors.on(:url).blank?
      this_host = URI.parse(url).host
      root_host = URI.parse(site.url).host
      unless this_host.match(root_host) or root_host.match(this_host)
        errors.add(:url, "This page's url has a different domain (#{this_host}) than the site's (#{root_host})")
      end
    end
  end
  
  def page_url_can_not_have_trailing_slashes
    if(url)
      errors.add(:url, "cannot have trailing slashes") unless url[url.length-1, 1]!='/'
    end
  end
end
