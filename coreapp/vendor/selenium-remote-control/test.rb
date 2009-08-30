#!/usr/bin/env ruby

# This script tests whether you have selenium-server and the
# selenium-client rubygem installed properly.
#
# You should see Firefox open, go to Google.com, do a search, and
# close. The server process should end with something like:
#    Got result: OK on session 5e16317d22a441afb731c13b319c5ba4
#
# Usage:
#    java -jar selenium-server.jar
#    ruby test.rb
require "rubygems"
require "selenium/client"

begin
  @browser = Selenium::Client::Driver.new \
  :host => "localhost",
    :port => 4444,
    :browser => "*firefox",
    :url => "http://www.google.com",
    :timeout_in_second => 60

  @browser.start_new_browser_session
  @browser.open "/"
  @browser.type "q", "Selenium seleniumhq.org"
  @browser.click "btnG", :wait_for => :page
  puts @browser.text?("seleniumhq.org")
ensure
  @browser.close_current_browser_session
end
