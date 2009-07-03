class Feedback < ActiveRecord::Base
  
  belongs_to :commenter
  belongs_to :page
  has_many :opinions, :dependent => :destroy, :validate => false
  
  validates_presence_of :page
  validates_associated :page
  validates_presence_of :commenter, :unless => :public
  validates_associated :commenter, :unless => :public
  
  validates_inclusion_of :public, :in => [true, false] # must be either public or private  
  validates_presence_of :name, :if => :public
  validate :has_valid_parent

  after_save :deliver_notification
  
  acts_as_nested_set
  
  @@popular_threshold = 2.0
  @@unpopular_threshold = 1.0 / @@popular_threshold
  @@high_vote_factor = 1.5
  @@avg_num_votes = {}
  
  def self.json_attribute_names
    %w(feedback_id name timestamp opinion agreed disagreed neutral? controversial? popular? unpopular?)
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
  
  def json_attributes(opinionated_commenter)
    json_atts = {}
    # self.class lets you get at a class method of anything that inherits from this object
    self.class.json_attribute_names.each do |attr|
      case attr
      when 'feedback_id'
        json_atts['feedback_id'] = id
      when 'name'
        json_atts['name'] = public ? name : commenter.truncated_email
      when 'timestamp'
        json_atts['timestamp'] = created_at.to_i
      when 'opinion'
        if opinionated_commenter
          json_atts['opinion'] = opinionated_commenter.opinion_of(id).to_s  # 'to_s' for nil => ''
        else
          json_atts['opinion'] = nil.to_s
        end
      when 'agreed'
        json_atts['agreed'] = self.agreed
      when 'disagreed'
        json_atts['disagreed'] = self.disagreed
      when 'neutral?'
        json_atts['neutral?'] = self.neutral?
      when 'popular?'
        json_atts['popular?'] = self.popular?
      when 'unpopular?'
        json_atts['unpopular?'] = self.unpopular?
      when 'controversial?'
        json_atts['controversial?'] = self.controversial?
      when 'isPrivate'
        json_atts['isPrivate'] = self.private
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
  
  def self.find_avg_num_votes(page_id)
    feedbacks = self.find_all_by_page_id(page_id)
    return 0 if feedbacks.empty?
    feedbacks.map(&:num_votes).sum / feedbacks.size
  end
  
  # HACK TO CACHE CRAP
  def self.avg_num_votes(page_id)
    if (! @@avg_num_votes[page_id])
      @@avg_num_votes[page_id] = Feedback.find_avg_num_votes(page_id)
    end
    @@avg_num_votes[page_id]
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
  
  protected
  def has_valid_parent
    if ! parent_id.nil?
      if ! parent.valid?
        errors.add(:parent, "Cannot create a feeedback with an invalid parent")
      end
    end
  end

  def deliver_notification
    Notification.put(self)
    true
  end
  
  
end
