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
  rc.additional_args << "-browserSessionReuse -log log/selenium_rc.log"
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

  def launch_app_servers(&block)    
    begin
      # start and run app servers for Outspokes and demo site for Selenium tests
      puts "starting Mongrels"
      # the following calls are asynchronous, you cannot rely on mongrels being immediately ready to listen
      system "mongrel_rails start --environment test --log log/selenium_coreapp.log --daemonize --port #{CONFIG.port} --pid tmp/pids/#{CONFIG.port}.pid"
      system "mongrel_rails start --environment test --log log/selenium_demoapp.log --daemonize --port #{CONFIG.selenium_demo_port} --pid tmp/pids/#{CONFIG.selenium_demo_port}.pid"
      
      # use the mongrels started above any way you please, but be gentle!
      yield block
      
    ensure
      # stop app servers for Outspokes and demo site after Selenium tests
      puts "stopping Mongrels"
      [ CONFIG.port, CONFIG.selenium_demo_port ].each do |port|
        system "mongrel_rails stop --pid tmp/pids/#{port}.pid"
      end
    end
  end
  
  desc "Runs all the selenium tests #{MAIN_TESTS} and #{BROWSER_SPECIFIC_TESTS} for BROWSER= (defaults to firefox), requires Selenium RC server to be started (rake selenium:rc:start)"
  task :test => :environment do
    raise "please set RAILS_ENV=test when running this rake task" unless RAILS_ENV == 'test'
    launch_app_servers do
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
end
