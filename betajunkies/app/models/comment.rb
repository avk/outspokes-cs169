class Comment < ActiveRecord::Base
		acts_as_taggable

	belongs_to :user
	belongs_to :project
	has_many :comments, :foreign_key => "parent"
	belongs_to :comment, :foreign_key => "parent"
	has_many :ratings

end
