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
    { :url => "http://www.runthisby.us/" }
  end

  def invalid_options_for_site
    valid = valid_options_for_site
    valid.shift # makes valid invalid
    valid # now invalid
  end

  def create_site(options = {})
    Site.create(valid_options_for_site.merge(options))
  end
  
  # Pages
  
  def valid_options_for_page_account 
    { :account_id => Account.find(:first).id, :url => 'http://runthisby.us' }
  end
  
  def valid_options_for_page_site
    { :site_id => Site.find(:first).id, :url => 'http://runthisby.us' }
  end
  
  def invalid_options_for_page
    valid = valid_options_for_page_account
    valid.shift
    valid
  end
  
  def create_page(options = {})
    Page.create(valid_options_for_page_account.merge(options))
  end

  # Commenters

  def valid_options_for_commenters
	{ :email => "abc@abc.com" }
  end

  def create_commenter(options = {})
    Commenter.create(valid_options_for_commenters.merge(options))
  end
  
  # Feedback
  
  def valid_options_for_feedback
    {:content=>'Hello, this is a feedback!'#, :page_id=>Page.find(:first).id, 
      #:commenter_id=>Commenter.find(:first).id
    }
  end
  
  def invalid_options_for_feedback
    valid = valid_options_for_feedback
    valid.shift # makes valid invalid
    valid # now invalid
  end
  
  def create_feedback(options={})
    Feedback.new(valid_options_for_feedback.merge(options))
  end
end
