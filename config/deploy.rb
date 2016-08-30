# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'homemade'
set :repo_url, 'https://github.com/d-theus/homemade.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

set :pty, true

set :chef_dir, File.expand_path('chef', File.dirname(__FILE__))

namespace :docker do
  namespace :compose do
    task :up do
      on roles :app do
        within current_path do
          execute 'docker-compose', 'up', '-d'
        end
      end
    end

    task :down do
      on roles :app do
        if test("[ -d #{current_path} ]") and capture('docker ps -q').lines.any?
          within current_path do
            execute 'docker-compose', 'down'
          end
        end
      end
    end

    task :onboot do
      on roles :app do
        execute "echo '@reboot cd #{current_path} && while [[ -z  $(#{capture 'which pgrep'} docker) ]]; do sleep 2; done && #{capture 'which docker-compose'} up -d' | crontab -"
      end
    end

    task :sitemap do
      on roles :app do
        within current_path do
          sleep 2
          execute 'docker-compose', 'exec', 'app1', 'bundle exec rake sitemap:refresh'
        end
      end
    end

    task :migrate do
      on roles :app do
        within current_path do
          sleep 2
          execute 'docker-compose', 'exec', 'app1', 'bundle exec rake db:migrate'
        end
      end
    end
  end

  task :persistence do
    config = YAML.load(File.read File.expand_path('docker-compose.yml'))
    on roles :app do
      config['volumes'].each do |_, val|
        name = val['external']['name']
        execute "docker volume ls | grep #{name} &>/dev/null; if [ $? -ne 0 ]; then docker volume create --name #{name}; fi"
      end
    end
  end
end

namespace :chef do
  task :cook do
    Dir.chdir(fetch :chef_dir) do
      nodes = JSON.parse(`knife search -z node "role:app" -a ipaddress -a name -F json 2>/dev/null`)["rows"]
      nodes.each do |node|
        puts "Another node: #{node.inspect}"
        node.keys.each do |k|
          attrs = node[k]
          system "knife solo cook admin@#{attrs['ipaddress']} -N #{attrs['name']}"
        end
      end
    end
  end
end

namespace :deploy do
  namespace :secrets do
    task :upload_env do
      on roles :app do
        upload! '.rbenv-vars', current_path
      end
    end

    task :upload_certs do
      on roles :app do
        files = Dir.glob('config/certs/*')
        execute "mkdir -p #{File.join current_path, 'config', 'certs'}" if files.any?
        files.each do |f|
          upload! f, File.join(current_path, 'config', 'certs', File.basename(f))
        end
      end
    end
  end

  after :updated,   'docker:compose:down'
  after :published, 'secrets:upload_env'
  after :published, 'secrets:upload_certs'
  after :published, 'docker:persistence'
  after :published, 'docker:compose:up'
  after :finished,  'docker:compose:migrate'
  after :finished,  'docker:compose:sitemap'
  after :finished,  'docker:compose:onboot'
end
