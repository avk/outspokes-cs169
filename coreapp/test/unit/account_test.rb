require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase

  def test_should_create_account
    assert_difference 'Account.count' do
      account = create_account
      assert !account.new_record?, "#{account.errors.full_messages.to_sentence}"
    end
  end


  def test_should_require_login
    assert_no_difference 'Account.count' do
      u = create_account(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_require_password
    assert_no_difference 'Account.count' do
      u = create_account(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Account.count' do
      u = create_account(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'Account.count' do
      u = create_account(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    commenters(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
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

end
