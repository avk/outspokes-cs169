require File.dirname(__FILE__) + '/../../test_helper'

class AdminPanel::CommentersControllerTest < ActionController::TestCase

  def setup
    @site = sites(:msn)
    @site.new_validation_token
    @alt_site = sites(:facebook)
  end

  def assert_invalid
    assert !flash[:error].nil?
    assert_template "admin_panel/invalid"
  end

  test "should list commenters for a site, excluding the admin" do
    get :index, :site_id => @site.id, :validation_token => @site.validation_token
    assert_template 'index'
    expected = @site.commenters.delete_if {|c| c.id == @site.account_id }
    got = assigns(:commenters)
    assert got == expected, "got #{got.inspect} instead of #{expected.inspect}"
  end
  
  test "should not list anything for an invalid site" do
    get :index, :site_id => 80870870987098098080808087, :validation_token => @site.validation_token
    assert_invalid
  end
  
  test "should not list anything for an invalid validation_token" do
    get :index, :site_id => @site.id, :validation_token => 'bullshit'
    assert_invalid
  end
  
  test "should not list anything for someone else's site" do
    get :index, :site_id => @alt_site.id, :validation_token => @site.validation_token
    assert_invalid
  end
  
  test "should create commenters" do
    emails = %w(avk@berkeley.edu hlhu@berkeley.edu mkocher@berkeley.edu)
    
    assert_difference 'Commenter.count', emails.size do
      assert_difference "Invite.count", emails.size do
        post :create, :site_id => @site.id, :emails => emails.join(', '), :validation_token => @site.validation_token
      end
    end
  
    assert_redirected_to admin_panel_commenters_path(@site)
  end
  
  test "should not invite duplicate commenters" do
    good_emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
    mixed_emails = [good_emails.first, "json@berkeley.edu"]
    num_new = (good_emails | mixed_emails).size
    assert_difference "Commenter.count", num_new do
      assert_difference "Invite.count", num_new do
        post :create, :site_id => @site.id, :emails => good_emails.join(', '), :validation_token => @site.validation_token
        post :create, :site_id => @site.id, :emails => mixed_emails.join(', '), :validation_token => @site.validation_token
      end
    end
  end
  
  test "should not invite invalid commenters" do
    bad_emails = %w(asdfasdfasfasd 987098709870987098 @.com)
    assert_no_difference "Commenter.count" do
      assert_no_difference "Invite.count" do
        post :create, :site_id => @site.id, :emails => bad_emails.join(', '), :validation_token => @site.validation_token
      end
    end
  end
  
  test "should not invite anyone given an invalid validation_token" do
    good_emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
    assert_no_difference "Commenter.count" do
      assert_no_difference "Invite.count" do
        post :create, :site_id => @site.id, :emails => good_emails.join(', '), :validation_token => 'bullshit'
      end
    end
    assert_invalid
  end
  
  test "should not invite anyone to someone else's site" do
    good_emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
    assert_no_difference "Commenter.count" do
      assert_no_difference "Invite.count" do
        post :create, :site_id => @alt_site.id, :emails => good_emails.join(', '), :validation_token => @site.id
      end
    end
    assert_invalid
  end

  test "should uninvite a commenter and delete his or her feedback for this site" do
    commenter = @site.commenters.first
    
    assert_difference("Invite.count", -1) do
      assert_difference "Feedback.count", -commenter.feedbacks_for_site(@site.id).size do
        delete :destroy, :site_id => @site.id, :id => commenter.id, :validation_token => @site.validation_token
      end
    end
    assert_redirected_to admin_panel_commenters_path(@site)
  end
  
  test "should not remove anything for an invalid site id" do
    commenter = Commenter.first
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => 982734098709870487230498723, :id => commenter.id, :validation_token => @site.validation_token
      end
    end
    assert_invalid
  end

  test "should not remove anything for an invalid commenter id" do
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => @site.id, :id => 982734098709870487230498723, :validation_token => @site.validation_token
      end
    end
    assert_invalid
  end
  
  test "should not uninvite anyone given a bad validation token" do
    commenter = @site.commenters.first
    
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => @site.id, :id => commenter.id, :validation_token => 'bullshit'
      end
    end
  end
  
  test "should not uninvite anyone for someone else's site" do
    commenter = @alt_site.commenters.first
    
    assert_no_difference "Invite.count" do
      assert_no_difference "Feedback.count" do
        delete :destroy, :site_id => @alt_site.id, :id => commenter.id, :validation_token => @site.validation_token
      end
    end
  end

end
