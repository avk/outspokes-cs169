set :application, "outspokes"

set :scm, :git
set :repository, "git@github.com:avk/feedback.git"
set :branch, "master"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/www/outspokes.com"


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, 'deploy'
ssh_options[:forward_agent] = true

set :use_sudo, false

role :app, "outspokes.com"
role :web, "outspokes.com"
role :db,  "outspokes.com", :primary => true

before "deploy", "backup"
before "deploy", "db:migrate"
before "deploy:restart", "deploy:remove_cached_assets"
after  "deploy:restart", "deploy:warm_up_app"

desc "Backup the database"
task :backup do
  run "cd #{current_path}/coreapp && RAILS_ENV=production rake backup"
end

namespace :db do
  task :migrate do
    run "cd #{current_path}/coreapp && RAILS_ENV=production rake db:migrate"
  end
end

## from http://www.zorched.net/2008/06/17/capistrano-deploy-with-git-and-passenger/
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{current_path}/coreapp/tmp" 
    run "touch #{current_path}/coreapp/tmp/restart.txt"
  end

  desc "Remove cached js and css"
  task :remove_cached_assets do
    run "rm -f #{current_path}/coreapp/public/stylesheets/*_cached.css"
    run "rm -f #{current_path}/coreapp/public/javascripts/*_cached.js"
  end

  task :warm_up_app do
    run "curl beta.outspokes.com > /dev/null"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

### from http://archive.jvoorhis.com/articles/2006/07/07/managing-database-yml-with-capistrano
### but modified, because it was from capistrano v1
desc "Create database.yml in shared/config" 
task :after_setup do
  database_configuration = <<-EOF

development:
  adapter: sqlite3
  database: db/development.sqlite3
  timeout: 5000

test:
  database: #{application}_testing
  adapter: mysql
  username: outspokes
  password: inktomi2009
  host: localhost
  socket: /var/run/mysqld/mysqld.sock
  
production:
  database: #{application}_production
  adapter: mysql
  username: outspokes
  password: inktomi2009
  host: localhost
  socket: /var/run/mysqld/mysqld.sock
EOF

  run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
  put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml" 
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/coreapp/config/database.yml" 
end

