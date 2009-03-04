class Site < ActiveRecord::Base
  
  has_many :pages, :order => "created_at ASC"
  belongs_to :account

#  validates_presence_of :url
#  validates_format_of :url, :with => URI.regexp(['http', 'https'])

  validates_presence_of :account_id
  validates_associated :account
  
  validate :has_home_page

#  after_save :create_home_page

#   def self.create_new_site(home_url, options = {})
#     s = Site.new(options)
#     p = Page.new({ :url => home_url })
#     begin
#       Site.transaction do
#         s.save_with_validation(false)
#         p.site = s
#         s.home_page = p
# #        if (not p.save) or (not s.save)
# #          raise ActiveRecord::Rollback, "Invalid site parameters" 
#         s.save!
#         p.save!
# #        end
#       end
#     rescue
#       return s
#     end
#     s
#   end

  def home_page
    self.pages.first
  end
  
  def home_page=(page)
    if (home_page)
      errors.add_to_base("Cannot set the homepage of a site once created")
    else
      self.pages << page
    end
  end
  
  def after_initialize

  end
  
 protected
 def has_home_page
   if not self.pages.first
     errors.add_to_base("Site must have a home_page to be valid")
   end
 end
#   def create_home_page(page)
#     self.pages << page
#   end

end
