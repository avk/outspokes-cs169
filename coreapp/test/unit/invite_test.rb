require File.dirname(__FILE__) + '/../test_helper'

class InviteTest < ActiveSupport::TestCase

  test 'should create invite' do
    assert_difference 'Invite.count' do
      i = create_invite
      assert !i.new_record?, "#{i.errors.full_messages.to_sentence}"
    end
  end
  
  test 'should require a page' do
    assert_no_difference "Invite.count" do
      i = create_invite(:page => nil)
      assert i.errors.on(:page), "allowing invites to be created without pages"
    end
  end
  
  test 'should require a valid page' do
    assert_no_difference "Invite.count" do
      i = create_invite(:page => Page.new(invalid_options_for_page))
      assert i.errors.on(:page), "allowing invites to be created with invalid pages"
    end
  end

  test 'should require a commenter' do
    assert_no_difference "Invite.count" do
      i = create_invite(:commenter => nil)
      assert i.errors.on(:commenter), "allowing invites to be created without commenters"
    end
  end
  
  test 'should require a valid commenter' do
    assert_no_difference "Invite.count" do
      i = create_invite(:commenter => Commenter.new(invalid_options_for_commenters))
      assert i.errors.on(:commenter), "allowing invites to be created with invalid commenters"
    end
  end

  test 'should generate a URL token after creation' do
    i = create_invite
    assert !i.new_record?, "#{i.errors.full_messages.to_sentence}"
    assert !i.url_token.nil?
  end
  
  test 'should not allow duplicate invites' do
    commenter = create_commenter
    i1, i2 = nil, nil
    
    assert_difference "Invite.count", 1 do
      i1 = create_invite(:page => pages(:fb_profile), :commenter => commenter)
      i2 = create_invite(:page => pages(:fb_profile), :commenter => commenter)
      assert !i1.new_record?, "#{i1.errors.full_messages.to_sentence}"
      assert i2.errors.on(:page_id), "#{i2.errors.full_messages.to_sentence}"
    end
  end
  
  test 'should generate unique URL tokens when inviting the same commenter to different pages' do
    commenter = create_commenter
    i1, i2 = nil, nil
    
    assert_difference "Invite.count", 2 do
      i1 = create_invite(:page => pages(:fb_profile), :commenter => commenter)
      i2 = create_invite(:page => pages(:rails_spikes), :commenter => commenter)
    end
    
    assert i1.url_token != i2.url_token
  end
  
  test "should generate unique URL tokens when inviting the same commenter at different times to pages with the same URL" do
    commenter = create_commenter
    i1, i2 = nil, nil
    s1 = create_site(:url => "http://www.bing.com")
    s2 = create_site(:url => "http://www.bing.com")
    
    assert_difference "Invite.count", 2 do
      i1 = create_invite(:page => s1.home_page, :commenter => commenter)
      sleep 1
      i2 = create_invite(:page => s2.home_page, :commenter => commenter)
    end
    
    assert i1.url_token != i2.url_token
  end
  
  test 'should return account who initiated the invite via inviter' do
    inviter = commenters(:aaron)
    commenter = commenters(:old_password_holder)
    
    assert_difference "Invite.count", 1 do
      i = create_invite(:commenter => commenter, :page => inviter.sites.first.pages.first)
      assert !i.new_record?
      assert i.inviter == inviter
    end
  end


end

