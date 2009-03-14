class Site < ActiveRecord::Base
  
  has_many :pages, :order => "created_at ASC", :dependent => :destroy
  belongs_to :account

  validates_presence_of :account_id
  validates_associated :account
  
  validate :has_valid_home_page
  
  before_validation :commit_home_page

  def home_page
    self.pages.first
  end
  
  def url=(url)
    if (home_page)
      raise Exception.new("Cannot set a URL for a site that already has a home_page: #{self}")
    end
    self.home_page = Page.new(:url => url, :site => self)
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
