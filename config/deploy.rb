# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'bgk'
set :deploy_user, 'mike'

set :filter, :roles => %w{app web}
set :scm, :git
set :repo_url, 'git@github.com:klishevich/bgk.git'
set :assets_roles, [:app]
set :keep_releases, 5
set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :tests, []
set(:config_files, %w(
  database.yml
  unicorn_init.sh
  secrets.yml
))
set(:executable_config_files, %w(
  unicorn_init.sh
))
set(:symlinks, [
  {
    # source: "/home/mike/apps/{{full_app_name}}/shared/config/unicorn_init.sh",
    # link: "/etc/init.d/unicorn_{{full_app_name}}"
  }
])

namespace :deploy do
  after 'deploy:publishing', 'deploy:restart'

  after :restart, :clear_cache do
    on roles(:app), in: :groups, limit: 4, wait: 10 do
	    before :deploy, "deploy:check_revision"
	    after :finishing, 'deploy:cleanup'
  	  after 'deploy:setup_config', 'nginx:reload'
      after 'deploy:publishing', 'deploy:restart'
    end
  end

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart2'
  end   

end

namespace :unicorn do

  desc 'Restart unicorn 2'
  task :restart2 do
    on roles(:app), in: :sequence, wait: 5 do
      execute "/etc/init.d/unicorn_bgk_production restart"
    end
  end  

end

