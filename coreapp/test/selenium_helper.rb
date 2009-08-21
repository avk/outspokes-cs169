ENV["RAILS_ENV"] = "test"
# require 'rake'
# require 'rake/testtask'
# require 'rake/rdoctask'
# require 'tasks/rails'
require 'test/test_helper'
require 'selenium/client'
require 'activesupport'

class SeleniumTestCase < Test::Unit::TestCase
  
  @@browser = nil
  cattr_accessor :browser
  
  # must be disabled for Selenium to access database changes during a test
  self.use_transactional_fixtures = false
  
  # classes that extend SeleniumTestCase and override SeleniumTestCase#setup should ALWAYS call 'super'
  def setup
    # Rake::Task['db:fixtures:load'].invoke # reload the fixtures since each test is NOT wrapped in a transaction
  end
  
  def self.open_browser(which)
    puts "opening #{which.capitalize}"
    @@browser = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*#{which}",
      :url => "http://dusk", 
      :timeout_in_second => 60

    @@browser.start_new_browser_session
  end

  def self.close_browser
    @@browser.close_current_browser_session
  end
  
end