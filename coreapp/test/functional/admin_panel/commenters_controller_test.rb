require File.dirname(__FILE__) + '/../../test_helper'

class AdminPanel::CommentersControllerTest < ActionController::TestCase

  def assert_invalid
    assert !flash[:error].nil?
    assert_template "admin_panel/invalid"
  end

  test "should list commenters for a site, excluding the admin" do
    site = sites(:linkedin)
    get :index, :site_id => site.id
    assert_template 'index'
    expected = site.commenters.delete_if {|c| c.id == site.account_id }
    got = assigns(:commenters)
    assert got == expected, "got #{got.inspect} instead of #{expected.inspect}"
  end
  
  test "should not list anything for an invalid site" do
    get :index, :site_id => 80870870987098098080808087
    assert_invalid
  end
  
  test "should create commenters" do
    site = sites(:linkedin)
    emails = %w(avk@berkeley.edu hlhu@berkeley.edu mkocher@berkeley.edu)
    
    assert_difference 'Commenter.count', emails.size do
      assert_difference "Invite.count", emails.size do
        post :create, :site_id => site.id, :emails => emails.join(', ')
      end
    end
  
    assert_redirected_to admin_panel_commenters_path(site)
  end
  
  test "should not invite duplicate commenters" do
    site = sites(:linkedin)
    good_emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
    mixed_emails = [good_emails.first, "json@berkeley.edu"]
    num_new = (good_emails | mixed_emails).size
    assert_difference "Commenter.count", num_new do
      assert_difference "Invite.count", num_new do
        post :create, :site_id => site.id, :emails => good_emails.join(', ')
        post :create, :site_id => site.id, :emails => mixed_emails.join(', ')
      end
    end
  end
  
  test "should not invite invalid commenters" do
    site = sites(:linkedin)
    bad_emails = %w(asdfasdfasfasd 987098709870987098 @.com)
    assert_no_difference "Commenter.count" do
      assert_no_difference "Invite.count" do
        post :create, :site_id => site.id, :emails => bad_emails.join(', ')
      end
    end
  end

  test "should uninvite a commenter and delete his or her feedback for this site" do
    site = sites(:linkedin)
    commenter = site.commenters.first
    
    assert_difference("Invite.count", -1) do
      assert_difference "Feedback.count", -commenter.feedbacks_for_site(site.id).size do
        delete :destroy, :site_id => site.id, :id => commenter.id
      end
    end
    assert_redirected_to admin_panel_commenters_path(site)
  end
  
  test "should not remove anything for an invalid site id" do
    commenter = Commenter.first
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => 982734098709870487230498723, :id => commenter.id
      end
    end
    assert_invalid
  end

  test "should not remove anything for an invalid commenter id" do
    site = sites(:linkedin)
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => site.id, :id => 982734098709870487230498723
      end
    end
    assert_invalid
  end

end
