class Feedback < ActiveRecord::Base
  
  belongs_to :page
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :content, :allow_blank => false
  
  validates_presence_of :target, :allow_blank => false
  
  def self.json_attribute_names
    %w(feedback_id name timestamp content target)
  end
  
  def abstract?
    return true
  end
  
  def initialize(*args, &block)
    if abstract?
      raise "Feedback cannot be instantiated.  Instantiate a subclass."
    end
    super(*args, &block)
  end
  
  def json_attributes
    json_atts = {}
    
    Feedback.json_attribute_names.each do |attr|
      case attr
      when 'feedback_id'
        json_atts['feedback_id'] = id
      when 'name'
        json_atts['name'] = commenter.email
      when 'timestamp'
        json_atts['timestamp'] = created_at.to_i
      else
        json_atts[attr] = self[attr.to_sym]
      end
    end
    
    json_atts
  end
  
  
end
