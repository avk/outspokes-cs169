require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  include NotificationTestHelper
  
  def test_must_not_be_abstract
    c = create_comment
    assert !c.abstract?
  end
  
  test "should create feedback" do
    assert_difference 'Comment.count' do
      feedback = create_comment
      assert !feedback.new_record?, "#{feedback.errors.full_messages.to_sentence}"
    end
  end

  test "should be associated with a commenter" do
    feedback = create_comment(:commenter => nil)
    assert !feedback.valid?
    # assert feedback.errors.on(:commenter_id), "allowing feedback to be saved without a commenter"
  end
      
  test "should be associated with a page" do
    feedback = create_comment(:page => nil)
    assert !feedback.valid?
  end
  
  test "should have content" do
    feedback = create_comment(:content => nil)
    assert !feedback.valid?
  end
  
  test "should not have blank content" do
    feedback = create_comment(:content => '')
    assert !feedback.valid?
  end
  
  test "should have a target" do
    feedback = create_comment(:target => '')
    assert !feedback.valid?
  end
  
  test "should expose certain attributes for json" do
    feedback = create_comment
    commenter = create_commenter
    opinion = commenter.opinions.create(:feedback => feedback, :agreed => true)
    
    json_atts = {
      "feedback_id" => feedback.id,
      "name" => feedback.commenter.truncated_email,
      "timestamp" => feedback.created_at.to_i,
      "content" => feedback.content,
      "target" => feedback.target,
      "opinion" => commenter.opinion_of(feedback.id),
      "agreed" => feedback.agreed,
      "disagreed" => feedback.disagreed,
      "neutral?" => feedback.neutral?,
      "controversial?" => feedback.controversial?,
      "popular?" => feedback.popular?,
      "unpopular?" => feedback.unpopular?,
      "isPrivate" => feedback.private
    }
    
    expected = json_atts.keys.sort
    got = Comment.json_attribute_names.sort
    assert got == expected, "Attributes don't match, expected: #{expected} but got: #{got}"
    feedback.json_attributes(commenter).each do |key, value|
      assert json_atts[key] == value, "for #{key}: expected #{json_atts[key].inspect} got #{value.inspect}"
    end
  end
  
  test 'should delete all opinions when deleted' do
    feedback = create_comment
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
    feedback = create_comment
    assert feedback.agreed == 0
  end

  test "should start with an disagreed count of 0" do
    feedback = create_comment
    assert feedback.disagreed == 0
  end

  test "should respond to agree_disagree_ratio" do
    feedback = create_comment
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
    page = pages(:lone_site)
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
    feedback = create_comment
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

  test "should return score of length of matching search term if it matches" do
    feedback = create_comment(:content => 'Bob is my friend')
    assert feedback.search_score("my") == 2
  end

  test "should return score of 0 if search term doesn't match" do
    feedback = create_comment(:content => 'Bob is my friend')
    assert feedback.search_score("whale") == 0
  end

  test "feedback should have lft" do
    feedback = create_comment
    assert !feedback.lft.nil?
  end

  test "feedback should have rgt" do
    feedback = create_comment
    assert !feedback.rgt.nil?
  end

  test "should not be case sensitive when searching" do
    feedback = create_comment(:content => 'Bob is my friend')
    assert feedback.search_score("MY") == 2
  end

  test "should return score of 50 if author contains search term" do
    feedback = create_comment(:content => 'Bob is my friend', :commenter_id => 1)
    assert feedback.search_score("MY") == 2
  end
  
end
