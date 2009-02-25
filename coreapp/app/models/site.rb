class Site < ActiveRecord::Base

  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp(['http', 'https'])

end
