class Opinion < ActiveRecord::Base
  
  belongs_to :feedback
  belongs_to :commenter
  
  validates_presence_of :feedback
  validates_associated :feedback
  
  validates_presence_of :commenter
  validates_associated :commenter
  
  validates_uniqueness_of :feedback_id, :scope => :commenter_id
  
  validates_inclusion_of :agreed, :in => [ true, false ]
  
protected

  def validate
    if commenter_id
      c = Commenter.find(commenter_id)
      if c.feedbacks.map(&:id).include?(feedback_id)
        errors.add_to_base "You cannot agree or disagree with your own feedback."
      end
    end
  end
  
end
