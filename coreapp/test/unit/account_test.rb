require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase

  def test_should_create_account
    assert_difference 'Account.count' do
      account = create_account
      assert !account.new_record?, "#{account.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_email
    assert_no_difference 'Account.count' do
      u = create_account(:email => nil)
      assert u.errors.on(:email)
    end
  end

  test "should require unique email" do
    create_account
    assert_no_difference 'Account.count' do
      u = create_account
      assert u.errors.on(:email)
    end
  end

  def test_should_require_password
    assert_no_difference 'Account.count' do
      u = create_account(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_not_allow_mass_assignment_outside_of_white_list
    u = create_account
    assert_no_difference 'u.crypted_password.size' do
      u.update_attributes(:crypted_password => 'much_longer_hacked_password')
    end
  end

  def test_should_reset_password
    commenters(:quentin).update_attributes(:password => 'new password')
    assert_equal commenters(:quentin), Account.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    commenters(:quentin).update_attributes(:email => 'quentin2@example.com')
    assert_equal commenters(:quentin), Account.authenticate('quentin2@example.com', 'monkey')
  end

  def test_should_authenticate_account
    assert_equal commenters(:quentin), Account.authenticate('quentin@example.com', 'monkey')
  end

  def test_should_set_remember_token
    commenters(:quentin).remember_me
    assert_not_nil commenters(:quentin).remember_token
    assert_not_nil commenters(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    commenters(:quentin).remember_me
    assert_not_nil commenters(:quentin).remember_token
    commenters(:quentin).forget_me
    assert_nil commenters(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    commenters(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil commenters(:quentin).remember_token
    assert_not_nil commenters(:quentin).remember_token_expires_at
    assert commenters(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    commenters(:quentin).remember_me_until time
    assert_not_nil commenters(:quentin).remember_token
    assert_not_nil commenters(:quentin).remember_token_expires_at
    assert_equal commenters(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    commenters(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil commenters(:quentin).remember_token
    assert_not_nil commenters(:quentin).remember_token_expires_at
    assert commenters(:quentin).remember_token_expires_at.between?(before, after)
  end

  test "should delete sites associated with it when destroyed" do
    account = nil
    
    assert_difference "Account.count" do
      account = create_account
    end
    
    urls = %w(http://www.google.com http://www.yahoo.com http://www.msn.com)
    assert_difference "Site.count", 3 do
      3.times do |url|
        account.sites << create_site(:account => account)
      end
      account.save
    end
    
    assert_difference "Account.count", -1 do
      assert_difference "Site.count", -3 do
        account.destroy
      end
    end
    
  end

  def test_should_be_able_to_find_a_site_by_its_domain
    account = commenters(:aaron)
    site = account.sites.first
    
    assert account.find_site_by_url(site.url) == site
  end

  test "reset_password should crypt a new password and deliver a reset email" do
    account = commenters(:quentin)
    old_crypted_password = account.crypted_password

    account.reset_password!

    assert_not_nil account.password, "temporary password should be set"
    assert Account.authenticate(account.email, account.password), "temporary password should work"
    assert_not_equal account.crypted_password, old_crypted_password, "new crypted password should be different than the old one"
    
    if password_email = ActionMailer::Base.deliveries.first
      assert password_email.body.include?(account.password), "new temporary password should be in the email body"
    else
      flunk("No password reset email was sent")
    end
  end

end
