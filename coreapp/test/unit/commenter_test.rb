require 'test_helper'

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

end
