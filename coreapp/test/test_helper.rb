ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper

  # Sites

  def valid_options_for_site
    valid_acct = commenters(:quentin)
    { :account => valid_acct, :url => "http://google.com" }
  end

  def invalid_options_for_site
    valid = valid_options_for_site
    valid[:url] = nil
    valid # now invalid
  end

  def create_site(options = {})
    Site.create(valid_options_for_site.merge(options))
  end
  
  # Pages
  
  def valid_options_for_page_account
    valid_acct = commenters(:quentin)
    { :url => 'http://runthisby.us', :account => valid_acct }
  end
  
  def valid_options_for_page_site
    valid_site = sites(:linkedin)
    { :url => valid_site.url + "/index.html", :site => valid_site }
  end
  
  # :url must be nil, PageController supplies account from session state
  def invalid_options_for_page
    valid = valid_options_for_page_account
    valid[:url] = nil
    valid
  end
  
  def create_page(options = {})
    Page.create(valid_options_for_page_account.merge(options))
  end

  # Commenters

  def valid_options_for_commenters
	{ :email => "abc@abc.com" }
  end

  def invalid_options_for_commenters
    { :email => "foo" }
  end

  def create_commenter(options = {})
    Commenter.create(valid_options_for_commenters.merge(options))
  end

  # Accounts
  
  def valid_options_for_account
    commenter = commenters(:one)
    {:commenter_id => commenter.id, :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }
  end
  
  def invalid_options_for_account
    valid = valid_options_for_account
    valid.shift # makes valid invalid
    valid # now valid
  end
  
  def create_account(options = {})
    record = Account.new(valid_options_for_account.merge(options))
    record.save
    record
  end
  
  # Feedback
  
  def valid_options_for_feedback
    page = pages(:one)
    commenter = commenters(:one)
    { :content=>'Hello, this is a feedback!', :page_id => page.id, :commenter_id => commenter.id }
  end
  
  def create_feedback(options={})
    Feedback.create(valid_options_for_feedback.merge(options))
  end
end
