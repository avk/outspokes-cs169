require File.dirname(__FILE__) + '/../test_helper'

class CommenterTest < ActiveSupport::TestCase

  test "successfully creates a commenter" do
    assert_difference 'Commenter.count' do
	  commenter = create_commenter
	  assert !commenter.new_record?, "#{commenter.errors.full_messages.to_sentence}"
    end
  end
  
  test "has an email address" do
    assert_no_difference 'Commenter.count' do
      commenter = create_commenter(:email => nil)
      assert commenter.errors.on(:email)
    end
  end

  test "should not allow a blank email" do
    assert_no_difference 'Commenter.count' do
	  commenter = create_commenter(:email => '')
      assert commenter.errors.on(:email)
    end
  end

  test "should give a valid email" do
    assert_no_difference 'Commenter.count' do
      commenter = create_commenter(:email => 'lulz')
      assert commenter.errors.on(:email)
    end
  end

  test "cannot give non-unique email" do
	  assert_difference 'Commenter.count' do
      commenter = create_commenter(:email => 'abc@abc.com')
    end  
  	assert_no_difference 'Commenter.count' do
       commenter2 = create_commenter(:email => 'abc@abc.com')
       assert commenter2.errors.on(:email)
    end
  end

  test "should parse email addresses" do
    legal = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
    illegal = ['bullshit', '@.com', '2394872039487323423432']
    results = Commenter.parse_email_addresses( (legal + illegal).join(', ') )
    assert legal == results[:legal]
    assert illegal == results[:illegal]
  end

  test "should respond to pages" do
    assert create_commenter.respond_to?(:pages)
  end

  test "should, when destroying a commenter, delete all feedback associated with it" do
    commenter = nil
    
    assert_difference "Commenter.count" do
      commenter = create_commenter
    end
    
    comments = %w(cool nifty awesome!)
    assert_difference "Feedback.count", comments.size do
      comments.each do |comment|
        commenter.feedbacks << create_comment(:content => comment, :commenter_id => commenter.id)
      end
      commenter.save
    end
    
    assert_difference "Commenter.count", -1 do
      assert_difference "Feedback.count", -(comments.size) do
        commenter.destroy
      end
    end
  end

  test 'should delete all associated invites when deleted' do
    commenter = create_commenter
    pages = %w(from_fb fb_profile)
    
    assert_difference "Invite.count", pages.size do
      pages.each do |page|
        Invite.create(:page => pages(page.to_sym), :commenter => commenter)
      end
    end
    
    assert_difference "Invite.count", -(pages.size) do
      commenter.destroy
    end
  end
  
  test 'should be able to agree with a feedback' do
    commenter = create_commenter
    feedback = create_comment
    
    assert_difference "Opinion.count", 1 do
      assert_difference "commenter.opinions.count", 1 do
        commenter.agree(feedback.id)
      end
    end
  end

  test 'should be able to disagree with a feedback' do
    commenter = create_commenter
    feedback = create_comment
    
    assert_difference "Opinion.count", 1 do
      assert_difference "commenter.opinions.count", 1 do
        commenter.disagree(feedback.id)
      end
    end
  end
  
  test 'should know if (s)he has no opinion of a feedback' do
    commenter = create_commenter
    feedback = create_comment
    
    assert commenter.opinion_of(feedback.id).nil?
  end
  
  test 'should have a special opinion on one of his/her own feedbacks' do
    commenter = create_commenter
    feedbacks = create_comment(:commenter => commenter)
    
    assert commenter.opinion_of(feedbacks.id) == 'mine'
  end
  
  test 'should know if (s)he has agreed with a feedback' do
    commenter = create_commenter
    feedback = create_comment
    
    commenter.opinions.create(:feedback => feedback, :agreed => true)
    assert commenter.opinion_of(feedback.id) == 'agreed'
  end
  
  test 'should know if (s)he has disagreed with a feedback' do
    commenter = create_commenter
    feedback = create_comment
    
    commenter.opinions.create(:feedback => feedback, :agreed => false)
    assert commenter.opinion_of(feedback.id) == 'disagreed'
  end
  
  test 'should be able to see a list of feedbacks (s)he agreed with' do
    commenter = commenters(:opinionated)
    agreed_with = [feedbacks(:one), feedbacks(:two), feedbacks(:three)]
    agreed_with.each do |fb|
      commenter.opinions.create(:feedback => fb, :agreed => true)
    end
    
    assert agreed_with.map(&:id).sort, commenter.agreed_with.map(&:id).sort
  end
  
  test 'should be able to see a list of feedbacks (s)he disagreed with' do
    commenter = commenters(:opinionated)
    disagreed_with = [feedbacks(:one), feedbacks(:two), feedbacks(:three)]
    disagreed_with.each do |fb|
      commenter.opinions.create(:feedback => fb, :agreed => false)
    end
    
    assert disagreed_with.map(&:id).sort, commenter.disagreed_with.map(&:id).sort
  end
  
  test 'should delete all of a commenter\'s opinions when that commenter is deleted' do
    commenter = create_commenter
    feedbacks = [:one, :two]

    assert_difference "commenter.opinions.count", feedbacks.size do
      feedbacks.each do |which|
        commenter.opinions.create(:feedback => feedbacks(which), :agreed => false)
      end      
    end
    
    assert_difference "Opinion.count", -(feedbacks.size) do
      commenter.destroy
    end
  end
  
  test 'should be able to get all of a commenter\'s feedbacks for a site' do
    site = sites(:linkedin)
    commenter = commenters(:aaron)
    
    page_ids = site.pages.map(&:id)
    expected = Feedback.find_all_by_commenter_id(commenter.id, :conditions => "page_id IN (#{ page_ids.join(',') })")
    got = commenter.feedbacks_for_site(site.id)
    assert got == expected, "got #{got.inspect} instead of #{expected.inspect}"
  end
  
  test 'should get an empty list if requesting all of a commenter\'s feedbacks for a site with a bad site id' do
    commenter = commenters(:aaron)
    assert [] == commenter.feedbacks_for_site(-987234)
  end
end
