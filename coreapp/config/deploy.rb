set :application, "outspokes"

set :scm, :git
set :repository, "git@github.com:avk/feedback.git"
set :branch, "master"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/www/beta.outspokes.com"


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, 'outspokes'
set :use_sudo, false

role :app, "outspokes.com"
role :web, "outspokes.com"
role :db,  "outspokes.com", :primary => true

## from http://www.zorched.net/2008/06/17/capistrano-deploy-with-git-and-passenger/
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end