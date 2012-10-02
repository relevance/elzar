require 'bundler/capistrano'

default_run_options[:pty] = true

set :application, "elzar_nightly_app"
set :repository, "/tmp/elzar_nightly_app" # TODO Find a way not to duplicate this path here and inside the spec. Pass as env arg?

set :user, 'deploy'
set :use_sudo, false
set :scm, :git
set :deploy_via, :copy
set(:deploy_to) { "/var/www/apps/#{application}" }
set(:server_ip) { ENV['SERVER_IP'] || raise("You must supply SERVER_IP") }

role :web, server_ip
role :app, server_ip
role :db,  server_ip, :primary => true


after 'deploy:update_code', 'deploy:symlink_configs'
after 'deploy:update_code', 'deploy:migrate'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs do
    shared_configs = File.join(shared_path,'config')
    release_configs = File.join(release_path,'config')
    run("ln -nfs #{shared_configs}/database.yml #{release_configs}/database.yml")
  end
end
