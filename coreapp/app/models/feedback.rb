class Feedback < ActiveRecord::Base
  
  belongs_to :commenter
  belongs_to :page
  has_many :opinions, :dependent => :destroy
  
  validates_presence_of :commenter_id
  validates_associated :commenter
  
  validates_presence_of :page_id
  validates_associated :page
  
  validates_presence_of :content, :allow_blank => false
  
  validates_presence_of :target, :allow_blank => false
  
  @@popular_threshold = 2.0
  @@unpopular_threshold = 1.0 / @@popular_threshold
  @@high_vote_factor = 1.5
  
  def self.json_attribute_names
    %w(feedback_id name timestamp content target opinion)
  end
  
  def json_attributes(opinionated_commenter)
    json_atts = {}
    
    Feedback.json_attribute_names.each do |attr|
      case attr
      when 'feedback_id'
        json_atts['feedback_id'] = id
      when 'name'
        json_atts['name'] = commenter.email
      when 'timestamp'
        json_atts['timestamp'] = created_at.to_i
      when 'opinion'
        json_atts['opinion'] = opinionated_commenter.opinion_of(id).to_s # 'to_s' for nil => ''
      else
        json_atts[attr] = self[attr.to_sym]
      end
    end
    
    json_atts
  end
  
  def agreed
    opinions.find_all_by_agreed(true).size
  end
  
  def disagreed
    opinions.find_all_by_agreed(false).size
  end
  
  
  def agree_disagree_ratio
    (disagreed > 0) ? (agreed.to_f / disagreed) : 0.0
  end
  
  def close_agree_disagree_ratio?
    (agree_disagree_ratio == 0.0) or
    (agree_disagree_ratio > @@unpopular_threshold and agree_disagree_ratio < @@popular_threshold)
  end
  
  
  def popular?
    agree_disagree_ratio >= @@popular_threshold
  end
  
  def unpopular?
    agree_disagree_ratio > 0.0 and agree_disagree_ratio <= @@unpopular_threshold
  end
  
  def self.popular(page_id)
    self.find_all_by_page_id(page_id).select {|fb| fb.popular? }
  end
  
  def self.unpopular(page_id)
    self.find_all_by_page_id(page_id).select {|fb| fb.unpopular? }
  end
  
  
  def num_votes
    agreed + disagreed
  end
  
  def self.avg_num_votes(page_id)
    feedbacks = self.find_all_by_page_id(page_id)
    feedbacks.map(&:num_votes).sum / feedbacks.size
  end
  
  def many_votes?
    num_votes > Feedback.avg_num_votes(page_id) * @@high_vote_factor
  end
  
  def few_votes?
    num_votes <= Feedback.avg_num_votes(page_id)
  end
  
  
  def controversial?
    many_votes? and close_agree_disagree_ratio?
  end
  
  def neutral?
    few_votes? and close_agree_disagree_ratio?
  end
  
  def self.controversial(page_id)
    self.find_all_by_page_id(page_id).select {|fb| fb.controversial? }
  end
  
  def self.neutral(page_id)
    self.find_all_by_page_id(page_id).select {|fb| fb.neutral? }
  end
  
end
