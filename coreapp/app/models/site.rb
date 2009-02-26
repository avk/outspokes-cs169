class Site < ActiveRecord::Base

  belongs_to :account

  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])

  validates_presence_of :account_id
  validates_associated :account

end
