class Page < ActiveRecord::Base



  belongs_to :site
  belongs_to :account

  has_many :invites, :dependent => :destroy
  has_many :commenters, :through => :invites
  has_many :feedbacks, :dependent => :destroy
  
  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])
  # validates_format_of :url, :with => URI.regexp(['.*'])
  validates_uniqueness_of :url, :scope => :account_id, :unless => Proc.new { |page| page.account_id.blank? }
  validates_uniqueness_of :url, :scope => :site_id, :unless => Proc.new { |page| page.site_id.blank? }
  validates_inclusion_of :allow_public_comments, :in => [true, false] # must be either public or private  
  
  validate :has_account_xor_site
  validate :is_child_of_site
  validate :publicness_matches_site, :if => :site
  validate :page_url_can_not_have_trailing_slashes
  
  
  def self.find_public_page_by_url(url)
    pages = Page.find_all_by_url url
    pages.reject! { |p| !p.allow_public_comments }
    return pages.empty? ? nil : pages[0]
  end
  

  def url=(url)
    if self.url and !self.site_id.blank?
      raise "Cannot set url for a page attached to a site"
    else
      super url
    end
  end

protected
  # A page can (and must!) have a site or an account, but not both
  def has_account_xor_site
    unless (account_id.blank? ^ site_id.blank?)
      errors.add_to_base 'Either an account or a site is required, but not both'
    end
  end
  
  # Verify that this url has the same domain as the associated Site's home_page's url
  def is_child_of_site
    # This validation is only relevant if this page belongs to a site; urls are validated seperately and shouldn't be checked here
    return true if site_id.blank? or url.nil?
    return true if id == site.home_page.id # If this _is_ the home_page, anything goes
    this_host = URI.parse(url).host
    root_host = URI.parse(site.url).host
    if this_host != root_host
      errors.add(:url, "This page's url has a different domain (#{this_host}) than the site's (#{root_host})")
    end
  end
  
  def publicness_matches_site
    return if (!site) || site.home_page.blank?
    unless allow_public_comments == site.public
      errors.add :allow_public_comments, "Page's privacy must match site"
    end
  end
  
  def page_url_can_not_have_trailing_slashes
    if(url)
      errors.add(:url, "Url can not have trailing slashes") unless url[url.length-1, 1]!='/'
    end
  end
end
