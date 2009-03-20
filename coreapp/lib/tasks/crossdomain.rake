require 'ruby-debug'

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
    ports.values.each do |port|
      system "mongrel_rails start --port #{port} -a 0.0.0.0 --pid $HOME/#{port}.pid -d"
    end
    
    sleep(10) # give the servers time to start
  end
  
  
  desc "stop #{apps.join(', ')}"
  task :stop_servers do
    puts "stopping Mongrels"
    ports.values.each do |port|
      system "mongrel_rails stop --pid $HOME/#{port}.pid"
    end
  end
  
  
  desc "Cross domain test based on 3/19/09 in-class demo"
  task :test => :start_servers do
    
    # add a new user to coreapp
    # add demoapp as a new site to coreapp
    # add a commenter for demoapp
    # validate that the commenter can see the JS interface on demoapp while others can't
    # post a comment to demoapp
    # view the comment on coreapp

    Rake::Task["crossdomain:stop_servers"].invoke
  end
end