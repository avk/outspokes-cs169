class Site < ActiveRecord::Base
  
  has_many :pages, :order => "created_at ASC", :dependent => :destroy
  belongs_to :account

  validates_presence_of :account_id
  validates_associated :account
  
  validate :has_valid_home_page
  
  before_validation :commit_home_page
  
  # If self.public is set before home_page is created, must remember to make home_page public
  @is_public = false
  
  def self.find_public_site_by_url(url)
    pub_pages = Page.find_all_by_allow_public_comments true
    current_site = nil
    longest_match = 0
    pub_pages.each do |page|
      if page.site.blank?
        next
      elsif url[0, page.url.length] == page.url && page.url.length > longest_match
        longest_match = page.url.length
        current_site = page.site
      end
    end
    return current_site
  end

  def home_page
    self.pages.first
  end
  
  def public
    # Rails keeps setting @is_public to nil. WTF?
    return home_page ? home_page.allow_public_comments : false | @is_public
  end
  
  def public=(pub)
    return if pub.nil?
    @is_public = pub
    pages.each { |page| page.allow_public_comments = pub }
  end
  
  def url=(url)
    if (home_page)
      raise Exception.new("Cannot set a URL for a site that already has a home_page: #{self}")
    end
    self.home_page = Page.new(:url => url, :site => self, :allow_public_comments => public)
  end
  
  def url
    if (not home_page)
      nil
    else
      home_page.url
    end
  end
  
  # Can't change home_page once site is created.  Just delete it and make a new site
  def home_page=(page)
    if (home_page)
      errors.add_to_base("Cannot set the homepage of a site once created")
    else
      self.pages << page
    end
  end
  


 def has_valid_home_page
   if !self.pages.first or !self.pages.first.valid?
     errors.add_to_base("Site must have a valid home_page to be valid")
   end
 end
 
 def commit_home_page
   if home_page and !home_page.valid?
     begin
       Site.transaction do
         save_with_validation(false)
         home_page.save!
         save!
       end
     rescue
       return false
     end
   end
   true
 end

end
