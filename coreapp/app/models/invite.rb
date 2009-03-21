class Invite < ActiveRecord::Base

  belongs_to :page
  belongs_to :commenter

  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :commenter_id
  validates_associated :commenter
  
  before_save :generate_url_token

private

  def generate_url_token
    # a long random string is a good salt: some random text's md5
    salt = '99fedcdf9e17b193a2eecb9e26a5e2fa'
    self.url_token = Digest::MD5::hexdigest(self.commenter.email + salt + self.page.url)
  end

end
