set :application, "outspokes"
set :scm, :git
set :repository, "git@github.com:avk/feedback.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/outspokes.com"
set :user, 'deploy'
set :use_sudo, false

ssh_options[:forward_agent] = true

# TODO: use capistrano roles, or switch to Rake or Vlad
desc "Settings for staging deployment"
task :staging do
  set :env_type, 'staging'
  role :app, "staging.outspokes.com"
  role :web, "staging.outspokes.com"
  role :db,  "staging.outspokes.com", :primary => true
end

desc "Settings for production deployment" 
task :production do
  set :env_type, 'production'
  role :app, "outspokes.com"
  role :web, "outspokes.com"
  role :db,  "outspokes.com", :primary => true
end

desc "Backup the database"
task :backup do
  run "cd #{current_path}/coreapp && RAILS_ENV=production rake backup"
end

desc "Loads the latest backup from /mnt/backup into prod db"
task :load_backup do
  run "cd #{current_path}/coreapp && RAILS_ENV=production rake load_backup"
end

namespace :db do
  task :migrate do
    run "cd #{current_path}/coreapp && RAILS_ENV=production rake db:migrate"
  end
end

## from http://www.zorched.net/2008/06/17/capistrano-deploy-with-git-and-passenger/
namespace :deploy do
  task :default do
    unless respond_to?(:env_type)
      puts "please specify 'staging' or 'production' before 'deploy'"
      exit 1
    end
    if env_type == 'staging' || "YES" == Capistrano::CLI.ui.ask("Did you test on staging? Are you sure you want to DEPLOY TO PRODUCTION?? (YES/no)")
      # deploy.web.disable

      # TODO: should be split up by roles and different tasks
      backup if env_type == 'production'

      # WARNING: load_backup will replace the prod db from latest backup
      load_backup if env_type == 'staging'

      deploy.update_code

      # symlinks current_path/coreapp/current, 'current_path' is
      # updated to this new release after this line.
      deploy.symlink

      deploy.symlink_database_yml
      deploy.symlink_log
      deploy.symlink_local_settings
      db.migrate
      deploy.remove_cached_assets
      deploy.restart
      # TODO: run tests? fail -> rollback
      # deploy.web.enable
      deploy.notify_hoptoad
    end
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{current_path}/coreapp/tmp" 
    run "touch #{current_path}/coreapp/tmp/restart.txt"
  end

  desc "Remove cached js and css"
  task :remove_cached_assets do
    run "rm -f #{current_path}/coreapp/public/stylesheets/*_cached.css"
    run "rm -f #{current_path}/coreapp/public/javascripts/*_cached.js"
    run "rm -f #{current_path}/coreapp/public/widget/*"
  end

  task :symlink_database_yml do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{current_path}/coreapp/config/database.yml" 
  end

  task :symlink_log do
    run "rm -rf #{current_path}/log"
    run "ln -nfs #{deploy_to}/#{shared_dir}/log #{current_path}/coreapp/log" 
  end

  task :symlink_local_settings do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/settings/local.rb #{current_path}/coreapp/config/settings/local.rb" 
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
