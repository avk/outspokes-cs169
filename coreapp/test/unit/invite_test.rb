require 'test_helper'

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
      assert i.errors.on(:page_id), "allowing invites to be created without pages"
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
      assert i.errors.on(:commenter_id), "allowing invites to be created without commenters"
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

end

