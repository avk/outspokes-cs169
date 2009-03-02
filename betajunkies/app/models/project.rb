class Project < ActiveRecord::Base

	belongs_to :user
	has_many :comments
	has_many :ratings
	
	validates_presence_of :link, :name, :user, :summary
	validates_format_of :link, :with => /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/
end
