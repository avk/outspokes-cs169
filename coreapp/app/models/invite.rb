class Invite < ActiveRecord::Base

  belongs_to :page
  belongs_to :commenter
  
  attr_protected :url_token
  
  validates_presence_of :page
  validates_associated :page

  validates_presence_of :commenter
  validates_associated :commenter
  
  validates_uniqueness_of :page_id, :scope => :commenter_id
  validates_uniqueness_of :url_token
  
  before_create :generate_url_token
  
  def inviter
    self.page.account
  end
  
  private

  def generate_url_token
    # a long random string is a good salt: some random text's md5
    salt = '99fedcdf9e17b193a2eecb9e26a5e2fa'
    self.url_token = Digest::MD5::hexdigest(self.commenter.email + salt + self.page.url + Time.now.to_s)
  end

end
