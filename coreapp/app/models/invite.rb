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
    self.url_token = self.commenter.email.crypt('a9') + self.page.url.crypt('37')
  end

end
