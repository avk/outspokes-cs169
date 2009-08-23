require 'test/test_helper'
require 'selenium/client'

class SeleniumTestCase < Test::Unit::TestCase
  cattr_accessor :browser

  # must be disabled for Selenium to access database changes during a test
  self.use_transactional_fixtures = false

  # classes that extend SeleniumTestCase and override SeleniumTestCase#setup should ALWAYS call 'super'
  # OPTIMIZE: open and close browser should be per file rather than per test
  def setup
    # reload the fixtures since each test is NOT wrapped in a transaction
    self.class.fixtures :all
    self.class.open_browser(ENV['BROWSER'])
  end

  def teardown
    self.class.close_browser
  end

  def self.open_browser(which)
    puts "opening #{which}"
    self.browser = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*#{which}",
      :url => "http://dusk",
      :timeout_in_second => 60

    self.browser.start_new_browser_session
  end

  def self.close_browser
    puts "closing browser"
    self.browser.close_current_browser_session
  end
end
