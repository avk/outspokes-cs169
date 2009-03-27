require 'ruby-debug'
require 'firewatir'
require File.expand_path(RAILS_ROOT + "/test/test_helper.rb")

include Test::Unit::Assertions

# Before Running Any of These Rake Tasks:
#   install mongrel gem
#   check that mongrel_rails in your path
#   (*nix) install firewatir gem
#   (*nix) install JSSh Firefox add-on: http://wtr.rubyforge.org/install.html
#   (*nix) disable all session management and crash recovery features in Firefox:
#         Firefox > Preferences > Main > When Firefox starts: > Show a blank page
#         (if installed) Session Manager > SessionStore > uncheck "Enable Crash Recovery"
#         (if installed) Tab Mix Plus > Session > uncheck the following: 
#           "Use Firefox's built-in Session Restore feature"
#           "Enable Session Manager"
#           "Enable Crash Recovery"
#   (*nix) Firefox should not be running
#   close anything on ports 3000, 3001, or whatever is listed in ports = { ... } below
#   run these tasks from feedback/coreapp

# These Rake Tasks Also Assume:
#   feedback/coreapp and feedback/demoapp are existing Rails apps
#   the $HOME environment variable points to a writeable directory
#   a coreapp database that supports transactions
#   a shell with kill, ps, grep, awk


namespace :crossdomain do
  
  base_path = File.expand_path("../")
  coreapp_path = File.join(base_path + "/coreapp").gsub(' ', '\ ')
  demoapp_path = File.join(base_path + "/demoapp").gsub(' ', '\ ')

  ports = {
    :coreapp_port => 3000,
    :demoapp_port => 3001
  }
  
  apps = ports.keys.map { |key| key.to_s.sub('_port', '') }
  
  
  desc "start and run #{apps.join(', ')}"
  task :start_servers do
    puts "starting Mongrels"
    system "cd #{coreapp_path}; mongrel_rails start --port #{ports[:coreapp_port]} -a 0.0.0.0 --pid $HOME/#{ports[:coreapp_port]}.pid -d"
    system "cd #{demoapp_path}; mongrel_rails start --port #{ports[:demoapp_port]} -a 0.0.0.0 --pid $HOME/#{ports[:demoapp_port]}.pid -d"
    
    wait_for = 5
    puts "waiting #{wait_for} seconds to give the servers time to start"
    sleep wait_for
  end
  
  
  desc "stop #{apps.join(', ')}"
  task :stop_servers do
    puts "stopping Mongrels"
    ports.values.each do |port|
      system "mongrel_rails stop --pid $HOME/#{port}.pid"
    end
  end
  
  
  desc "Cross domain test based on 3/19/09 in-class demo"
  task :test => :environment do
    Rake::Task["crossdomain:start_servers"].invoke
    
    user, site = nil, nil
    commenter, invite = nil, nil
    
    begin
      ActiveRecord::Base.transaction do
        
        # add a new user to coreapp
        puts "creating an account"
        assert_difference "Account.count" do
          user = Account.create(:email => 'zack@nefarious.com', :password => 'password', :password_confirmation => 'password')
        end
        
        # add demoapp as a new site to coreapp
        url = "http://localhost:#{ports[:demoapp_port]}/octave/octave.html"
        puts "creating site with url: #{url}"
        assert_difference "Site.count" do
          site = Site.create(:account => user, :url => url)
        end
        
        # add a commenter for demoapp
        puts "inviting a commenter"
        assert_difference "Commenter.count" do
          assert_difference "Invite.count" do
            Commenter.transaction do
              commenter = Commenter.new(:email => "clyvedjames@twitter.com")
              commenter.save!
              invite = Invite.new(:commenter => commenter, :page => site.home_page)
              invite.save!
            end
          end
        end
        
      end
      
      puts "Test data created in coreapp db, launching demoapp..."
      
      # validate that the commenter can see the JS interface on demoapp while others can't
      begin
        browser = Watir::Browser.new
        puts "waiting 3 seconds for Firefox to start up completely"
        sleep 3
        noninvite_url = site.home_page.url
        invite_url = noninvite_url + "?url_token=#{invite.url_token}"
        
        # uninvited visitors shouldn't see our JS interface
        puts "fetching #{noninvite_url}"
        browser.goto(noninvite_url)
        assert !browser.div(:id, "feedback_wrapper").exists?, "div#feedback_wrapper exists at the non invite URL: #{noninvite_url}"
        
        # invited visitors should see our JS interface
        puts "fetching #{invite_url}"
        browser.goto(invite_url)        
        assert browser.div(:id, "feedback_wrapper").exists?, "div#feedback_wrapper does NOT exist at the invite URL: #{invite_url}"
        
        # post a comment to demoapp
        my_feedback = "my most awesomest of sauciest feedback"
        browser.div(:id, "feedback_wrapper").click
        puts "waiting for the comment form to be rendered..."
        sleep 3
        browser.text_field(:name, 'content').set(my_feedback)
        f = browser.form(:name, "newcomment")
        f.submit
        f.onsubmit
        # TODO: refactor to find the posted feedback specifically in the list of comments
        assert browser.contains_text(my_feedback), "browser does not display the feedback the commenter has left"
        
        # verify the comment is on coreapp
        # TODO: the following assertion is nondeterministic
        assert Feedback.find_by_content(my_feedback), "the feedback the commenter has left is not in the coreapp database: #{Feedback.find(:all).map(&:content)}"
        
      rescue Exception => e
        puts e
      ensure
        # Dear God in Heaven, I wish I didn't have to do this but browser.close doesn't kill Firefox :/
        system("kill -15 `ps aux | grep firefox | grep -v grep | awk '{print $2}'`")
      end
      
    rescue Exception => e
      puts e
    ensure
      user.destroy
      site.destroy
      commenter.destroy
      invite.destroy
      Feedback.destroy_all
      Rake::Task["crossdomain:stop_servers"].invoke
    end
  end
end