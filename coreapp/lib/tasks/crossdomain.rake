require 'ruby-debug'
require 'firewatir'

# ENV["RAILS_ENV"] = "test"
# require File.expand_path(RAILS_ROOT + "/config/environment")
# require 'test_help'
require File.expand_path(RAILS_ROOT + "/test/test_helper.rb")

include Test::Unit::Assertions

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
    # ports.values.each do |port|
    #   system "mongrel_rails start --port #{port} -a 0.0.0.0 --pid $HOME/#{port}.pid -d"
    # end
    system "cd #{coreapp_path}; mongrel_rails start --port #{ports[:coreapp_port]} -a 0.0.0.0 --pid $HOME/#{ports[:coreapp_port]}.pid -d"
    system "cd #{demoapp_path}; mongrel_rails start --port #{ports[:demoapp_port]} -a 0.0.0.0 --pid $HOME/#{ports[:demoapp_port]}.pid -d"
    
    # sleep(10) # give the servers time to start
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
              invite = Invite.new(:commenter => nil, :page => site.home_page)
              invite.save!
            end
          end
        end
  
        # TODO: validate that the commenter can see the JS interface on demoapp while others can't
        invite_url = url + "?url_token=#{invite.url_token}"
        puts "fetching #{invite_url}"
  
        begin
          browser = Watir::Browser.start(invite_url)
          
          print "a div with id feedback_wrapper " 
          if browser.div(:id, "feedback_wrapper").nil?
            print "does NOT exist"
          else
            print "exists"
          end
          puts " on this page: #{invite_url}"
          
          # TODO: post a comment to demoapp
          # TODO: view the comment on coreapp
        rescue Exception => e
          raise e # so that it will roll back the transaction
        ensure
          # Dear God in Heaven, I wish I didn't have to do this but browser.close doesn't kill Firefox :/
          system("kill -15 `ps aux | grep firefox | grep -v grep | awk '{print $2}'`")
        end
        
        raise ActiveRecord::Rollback, "Cleaning up the database."
      end
    rescue
      puts "Something went wrong at the database level..."
      puts "you may have to manually run \n\t rake crossdomain:stop_servers"
    ensure
      Rake::Task["crossdomain:stop_servers"].invoke
    end
  end
end