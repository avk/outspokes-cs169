require 'selenium/rake/tasks'

# selenium:rc:start
# http://selenium-client.rubyforge.org/classes/Selenium/Rake/RemoteControlStartTask.html
Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
  rc.background = true
  rc.wait_until_up_and_running = true
  rc.jar_file = File.join(RAILS_ROOT + "/vendor/selenium-remote-control/selenium-server.jar")
  # rc.additional_args << "-singleWindow" # left out because it hinders cross-domain communication
  rc.additional_args << "-browserSessionReuse"
end

# selenium:rc:stop
# http://selenium-client.rubyforge.org/classes/Selenium/Rake/RemoteControlStopTask.html
Selenium::Rake::RemoteControlStopTask.new do |rc|
  rc.host = "localhost"
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
end


namespace :selenium do

  SUPPORTED_BROWSERS = ['firefox', 'safari']
  DEFAULT_BROWSER = SUPPORTED_BROWSERS.first
  
  MAIN_TESTS = 'test/selenium/**/*_test.rb'
  BROWSER_SPECIFIC_TESTS = 'test/selenium/browser_specific/'

  desc "Runs all the selenium tests #{MAIN_TESTS} and #{BROWSER_SPECIFIC_TESTS} for BROWSER= (defaults to firefox)"
  task :test do
    ENV['BROWSER'] ||= DEFAULT_BROWSER
    browser_name = ENV['BROWSER'].downcase
    unless SUPPORTED_BROWSERS.include?(browser_name)
      raise "Sorry, I don't recognize that browser! Only #{SUPPORTED_BROWSERS.join(', ')} are supported."
    end
    puts "Don't forget to ENABLE popups in your #{browser_name.capitalize}'s preferences" if browser_name != DEFAULT_BROWSER
    
    Rake::TestTask.new(:browser_test) do |t|
      t.libs << 'test'
      t.test_files = FileList.new(MAIN_TESTS, BROWSER_SPECIFIC_TESTS + "*#{browser_name}*.rb")
      t.verbose = true
    end
    task(:browser_test).invoke
  end
end
