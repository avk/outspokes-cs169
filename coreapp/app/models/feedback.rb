class Feedback < ActiveRecord::Base
  
  belongs_to :page
  belongs_to :commenter
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_inclusion_of :public, :in => [true, false] # must be either public or private  
  validates_presence_of :name, :if => :public
  validates_presence_of :commenter_id, :unless => :public
  validates_associated :commenter, :unless => :public
  
  
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
        json_atts['name'] = public ? name : commenter.email
      when 'timestamp'
        json_atts['timestamp'] = created_at.to_i
      else
        json_atts[attr] = self[attr.to_sym]
      end
    end
    
    json_atts
  end
  
end
