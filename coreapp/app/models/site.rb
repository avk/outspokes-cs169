class Site < ActiveRecord::Base
  
  has_many :pages, :order => "created_at ASC"
  belongs_to :account

  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])

  validates_presence_of :account_id
  validates_associated :account

  after_save :create_home_page

  def home_page
    self.pages.first
  end
  
protected
  def create_home_page
    self.pages << Page.new(:url => url)
  end

end
