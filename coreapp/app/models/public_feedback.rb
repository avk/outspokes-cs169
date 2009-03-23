class PublicFeedback < AbstractFeedback
  
  validates_presence_of :name
  
  def json_attributes
    json_atts = {}
    
    Feedback.json_attribute_names.each do |attr|
      case attr
      when 'feedback_id'
        json_atts['feedback_id'] = id
      when 'timestamp'
        json_atts['timestamp'] = created_at.to_i
      else
        json_atts[attr] = self[attr.to_sym]
      end
    end
    
    json_atts
  end
  
end
