class Feedback < ActiveRecord::Base
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :commenter_id
  validates_associated :commenter
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :content, :allow_blank => false
  
  validates_presence_of :target, :allow_blank => false
  
  def self.public_attribute_names
    %w(id created_at content target)
  end
  
  def public_attributes
    attributes.delete_if { |attribute, value| !Feedback.public_attribute_names.include?(attribute) }
  end
  
end
