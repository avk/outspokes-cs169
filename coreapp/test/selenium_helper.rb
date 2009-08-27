ENV["RAILS_ENV"] = "test"
require 'test/test_helper'
require 'selenium/client'

class SeleniumTestCase < Test::Unit::TestCase
  include ActionController::UrlWriter
  cattr_accessor :browser
  @@testing_browser = ENV['BROWSER'] || 'firefox'
  @@default_url_options = { :host => CONFIG.selenium_demo_domain }

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
      :url => CONFIG.selenium_demo_url,
      :timeout_in_second => 60

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

end
