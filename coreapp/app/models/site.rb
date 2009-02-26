class Site < ActiveRecord::Base
  has_many :pages

  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])

end
