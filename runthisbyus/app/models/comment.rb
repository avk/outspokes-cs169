class Comment < ActiveRecord::Base

  belongs_to :idea

  validates_presence_of :author, :allow_blank => false
  validates_format_of :author, :with => /^\w+$/i

  validates_presence_of :body, :allow_blank => false

  validates_presence_of :idea_id
  validates_associated :idea

end
