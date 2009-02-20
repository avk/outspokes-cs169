class Idea < ActiveRecord::Base

  has_many :comments

  validates_presence_of :name
  validates_presence_of :body

end
