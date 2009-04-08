class Feedback < ActiveRecord::Base
  
  belongs_to :commenter
  belongs_to :page
  
  validates_presence_of :commenter_id
  validates_associated :commenter
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :content, :allow_blank => false
  
  validates_presence_of :target, :allow_blank => false
  
  def self.json_attribute_names
    %w(feedback_id name timestamp content target)
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
  
  def search_score(terms) 
    score = 0
    terms.map{|term| if(self.content.downcase.include? term.downcase) then score += term.length; end}
    score
  end
  
end
