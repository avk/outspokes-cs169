ENV["RAILS_ENV"] = "test"
require 'test/test_helper'
require 'selenium/client'

class SeleniumTestCase < Test::Unit::TestCase
  include ActionController::UrlWriter
  cattr_accessor :browser
  @@testing_browser = ENV['BROWSER'] || 'firefox'

  # must be disabled for Selenium to access database changes during a test
  self.use_transactional_fixtures = false

  # classes that extend SeleniumTestCase and override SeleniumTestCase#setup should ALWAYS call 'super'
  def setup
    # reload the fixtures since each test is NOT wrapped in a transaction
    self.class.fixtures :all
    self.class.open_browser(@@testing_browser)
  end

  def teardown
    self.class.close_browser
  end

  def self.open_browser(which)
    @@browser = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*#{which}",
      :url => 'http://' + @@default_url_options[:host],
      :timeout_in_second => 5

    @@browser.start_new_browser_session
  end

  def self.close_browser
    @@browser.close_current_browser_session
  end

  def home_page
    @@browser.click "home_link"
  end

  def register_account(options = {})
    options.reverse_merge!(valid_options_for_account)
    @@browser.open signup_path
    @@browser.type "account_name", options[:name]
    @@browser.type "account_job_title", options[:job_title]
    @@browser.type "account_email", options[:email]
    @@browser.type "account_password", options[:password]
    @@browser.click "new-account-submit", :wait_for => :page
    assert_equal new_site_url, @@browser.location, "should redirect to new site creation on successful registration"
  end

  def login_account(options = {})
    options.reverse_merge!(valid_options_for_account)
    @@browser.click 'login-link', :wait_for => :page
    @@browser.type "email", options[:email]
    @@browser.type "password", options[:password]
    @@browser.click "login-account-submit", :wait_for => :page
    account = Account.find_by_email(options[:email])
    assert_equal dashboard_account_url(account), @@browser.location
  end

  def logout_account(options = {})
    @@browser.click 'logout-link', :wait_for => :page
    assert_equal root_url, @@browser.location
  end
end
