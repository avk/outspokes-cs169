require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test "should create feedback" do
    assert_difference 'Feedback.count' do
      feedback = create_feedback
      assert !feedback.new_record?, "#{feedback.errors.full_messages.to_sentence}"
    end
  end
  
  test "should be associated with a commenter" do
    feedback = create_feedback(:commenter => nil)
    assert !feedback.valid?
    # assert feedback.errors.on(:commenter_id), "allowing feedback to be saved without a commenter"
  end
      
  test "should be associated with a page" do
    feedback = create_feedback(:page => nil)
    assert !feedback.valid?
  end
  
  test "should have content" do
    feedback = create_feedback(:content => nil)
    assert !feedback.valid?
  end
  
  test "should not have blank content" do
    feedback = create_feedback(:content => '')
    assert !feedback.valid?
  end
  
  test "should have a target" do
    feedback = create_feedback(:target => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes for json" do
    feedback = create_feedback
    json_atts = {
      "feedback_id" => feedback.id,
      "name" => feedback.commenter.email,
      "timestamp" => feedback.created_at.to_i,
      "content" => feedback.content,
      "target" => feedback.target
    }
    
    assert Feedback.json_attribute_names.sort == json_atts.keys.sort
    feedback.json_attributes.each do |key, value|
      assert json_atts[key] == value
    end
  end
  
  test 'should delete all opinions when deleted' do
    feedback = create_feedback
    commenters = Commenter.find(:all, :order => "created_at DESC", :limit => 5)
    num_opinions = commenters.size
    
    assert_difference "Opinion.count", num_opinions do
      commenters.each do |c|
        c.opinions.create(:feedback => feedback, :agreed => true)
      end
    end
    
    assert_difference "Opinion.count", -(num_opinions) do
      feedback.destroy
    end
  end
  
  test "should start with an agreed count of 0" do
    feedback = create_feedback
    assert feedback.agreed == 0
  end
  
  test "should start with an disagreed count of 0" do
    feedback = create_feedback
    assert feedback.disagreed == 0
  end

  test "should respond to agree_disagree_ratio" do
    feedback = create_feedback
    assert feedback.agree_disagree_ratio == 0.0
  end
  
  test "should detect an inconclusive (i.e. close) agree_disagree_ratio" do
    feedback = feedbacks(:controversial1)
    assert feedback.close_agree_disagree_ratio?
  end
  
  test "should respond to popular?" do
    popular = feedbacks(:popular1)
    assert popular.popular?
    unpopular = feedbacks(:unpopular1)
    assert !unpopular.popular?
  end
  
  test "should respond to unpopular?" do
    unpopular = feedbacks(:unpopular1)
    assert unpopular.unpopular?
    popular = feedbacks(:popular1)
    assert !popular.unpopular?
  end
  
  test "should fetch a list of popular feedbacks" do
    popular = []
    (1..3).each { |i| popular << feedbacks("popular#{i}".to_sym) }
    
    fetched = Feedback.popular(popular.first.page_id)
    assert fetched.map(&:id).sort == popular.map(&:id).sort, 
      "got #{fetched.inspect} instead of #{popular.inspect}"
  end
  
  test "should fetch a list of unpopular feedbacks" do
    unpopular = []
    (1..3).each { |i| unpopular << feedbacks("unpopular#{i}".to_sym) }
    
    fetched = Feedback.unpopular(unpopular.first.page_id)
    assert fetched.map(&:id).sort == unpopular.map(&:id).sort, 
      "got #{fetched.inspect} instead of #{unpopular.inspect}"
  end
  
  test "should respond to num_votes" do
    feedback = feedbacks(:popular1)
    assert feedback.agreed == 9
    assert feedback.disagreed == 4
    assert feedback.num_votes == 13
  end
  
  test "should know the average number of votes per page" do
    page = pages(:lone)
    actual = Feedback.avg_num_votes(page.id)
    expected = 10
    assert actual == expected, "got #{actual}, expected #{expected}"
  end
  
  test "should be able to tell if a feedback has many votes" do
    f = feedbacks(:avg3)
    assert f.many_votes?
  end
  
  test "should be able to tell if a feedback has few votes" do
    f = feedbacks(:avg1)
    assert f.few_votes?
  end
  
  test "should respond to controversial?" do
    feedback = feedbacks(:controversial1)
    assert !feedback.popular?
    assert !feedback.unpopular?
    assert !feedback.neutral?
    assert feedback.controversial?
  end
  
  test "should fetch a list of controversial feedbacks" do
    controversial = []
    (1..3).each { |i| controversial << feedbacks("controversial#{i}".to_sym) }
    
    fetched = Feedback.controversial(controversial.first.page_id)
    assert fetched.map(&:id).sort == controversial.map(&:id).sort, 
      "got #{fetched.inspect} instead of #{controversial.inspect}"
  end
  
  test "should respond to neutral?" do
    feedback = create_feedback
    assert feedback.neutral?
  end
  
  test "should fetch a list of neutral feedbacks" do
    Feedback.neutral(feedbacks(:neutral).page_id).each do |fb|
      assert !fb.popular?
      assert !fb.unpopular?
      assert !fb.controversial?
      assert fb.neutral?
    end
  end
  
end
