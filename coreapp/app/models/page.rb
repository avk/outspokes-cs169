class Page < ActiveRecord::Base

  has_many :invites
  has_many :commenters, :through => :invites
  belongs_to :site
  belongs_to :account

  has_many :feedbacks
  
  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])
  validates_uniqueness_of :url, :scope => :account_id, :unless => Proc.new { |page| page.account_id.blank? }
  validates_uniqueness_of :url, :scope => :site_id, :unless => Proc.new { |page| page.site_id.blank? }
  
  validate :has_account_xor_site

protected
  # A page can (and must!) have a site or an account, but not both
  def has_account_xor_site
    if not (account_id.blank? ^ site_id.blank?)
      errors.add_to_base 'Either an account or a site is required, but not both'
    end
  end
  
end
