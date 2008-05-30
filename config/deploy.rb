default_run_options[:pty] = true

set :application, "asacalow.co.uk"
set :repository,  "git://github.com/asacalow/asacalow.co.uk.git"

set :user, "asacalow"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/merb/#{application}"

# server variables
set :adapter, "ebb"
set :processes, 2
set :log_path, "#{shared_path}/log/production.log"  

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :deploy_via, :remote_cache

role :app, "asacalow.co.uk"
role :web, "asacalow.co.uk"
role :db,  "asacalow.co.uk", :primary => true

after 'deploy:update', 'twitter:upload_config'

namespace "deploy" do
  task :start do
    run "cd #{current_path}; merb -a #{adapter} -c #{processes} -L #{log_path}"
  end

  task :stop do
    run "cd #{current_path};merb -a #{adapter} -k all"
  end

  task :restart do
    stop
    start
    apache.restart
  end
  
  desc "Restart apache"
  namespace "apache" do
    task :restart do
      sudo "/etc/init.d/apache2 restart"
    end
  end
end

namespace "twitter" do
  desc "Upload your Twitter config to the server"
  task :upload_config do
    upload "config/twitter.yml", "#{current_path}/config/twitter.yml"
  end
end