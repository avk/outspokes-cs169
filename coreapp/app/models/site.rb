class Site < ActiveRecord::Base
  
  has_many :pages, :order => "created_at ASC"
  belongs_to :account

#  validates_presence_of :url
#  validates_format_of :url, :with => URI.regexp(['http', 'https'])

  validates_presence_of :account_id
  validates_associated :account

#  after_save :create_home_page

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
  
# protected
#   def create_home_page(page)
#     self.pages << page
#   end

end
