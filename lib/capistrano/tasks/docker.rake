namespace :docker do
  task :stop  => %w(proxy:stop servers:stop uploads:stop public:stop)
  task :start => %w(db:start public:start uploads:start servers:start proxy:start)
  task :restart => %w(stop start)
  task :clear => %w(proxy:clear servers:clear public:clear)
  task :setup => %w(clear public:setup public:start uploads:start servers:setup proxy:setup)
  task :deploy => %w(setup start)

  namespace :servers do
    task :setup do
      on roles :app do
        within current_path do
          execute :docker, "stop #{fetch :db} || true"
          execute :docker, "build -t rails ."
          execute :docker, "rm -f #{fetch :rails}-tmp || true"
          execute :docker, "run --name #{fetch :rails}-tmp -it #{fetch :volumes} #{fetch :rails} rbenv exec rake assets:precompile"
          execute :docker, "commit #{fetch :rails}-tmp #{fetch :rails}"
          execute :docker, "rm -f #{fetch :rails}-tmp || true"
          execute :docker, "start #{fetch :db} || true"
          execute "while [ ! $(docker ps --filter=\"name=#{fetch :db}\" -q) ]; do echo \"waiting for :db\"; sleep 2s; done; sleep 10s;"
          execute :docker, "run --name #{fetch :rails}-tmp -it --link #{fetch :db} #{fetch :volumes} #{fetch :rails} rbenv exec rake sitemap:refresh"
          execute :docker, "stop #{fetch :db} || true"
          execute :docker, "commit #{fetch :rails}-tmp #{fetch :rails}"
          execute :docker, "rm #{fetch :rails}-tmp || true"
          execute :docker, "start #{fetch :db} || true"
          execute "while [ ! $(docker ps --filter=\"name=#{fetch :db}\" -q) ]; do echo \"waiting for :db\"; sleep 2s; done; sleep 10s;"
          execute :docker, "run --name #{fetch :rails}-tmp -it --link #{fetch :db} #{fetch :volumes} #{fetch :rails} rbenv exec rake db:migrate"
          execute :docker, "commit #{fetch :rails}-tmp #{fetch :rails}"
          execute :docker, "rm #{fetch :rails}-tmp || true"
          for i in fetch(:http_backends)
            execute :docker, "run --name #{fetch :rails}#{i} -d --link #{fetch :db} --link #{fetch :smtp} #{fetch :volumes} #{fetch :rails} rbenv exec bundle exec #{fetch :backend} start"
          end
          for i in fetch(:https_backends)
            execute :docker, "run --name #{fetch :rails}#{i} -d --link #{fetch :db} --link #{fetch :smtp} #{fetch :volumes} #{fetch :rails} rbenv exec bundle exec #{fetch :backend} start --ssl"
          end
        end
      end
    end

    task :clear => :stop do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute :docker, "rm -f #{fetch :rails}#{i} || true"
        end

        execute :docker, "rm -f #{fetch :rails}-tmp || true"
      end
    end

    task :start do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute :docker, "start #{fetch :rails}#{i}"
        end
      end
    end

    task :stop do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute %Q(
          if [ $(docker ps --filter="name=#{fetch :rails}" -q) ]
            then docker stop #{fetch :rails}
          fi)
        end
      end
    end
  end

  namespace :proxy do
    task :setup do
      on roles :app do
        execute :docker, "run -d --name #{fetch :proxy} #{fetch :proxy_links} #{fetch :volumes} -p 80:80 -p 443:443 #{fetch :proxy}"
      end
    end

    task :clear => :stop do
      on roles :app do
        execute :docker, "rm -f #{fetch :proxy} || true"
      end
    end

    task :start do
      on roles :app do
        execute :docker, "start #{fetch :proxy}"
      end
    end

    task :stop do
      on roles :app do
        execute %Q(
        if [ $(docker ps --filter="name=#{fetch :proxy}" -q) ]
        then docker stop #{fetch :proxy}
        fi)
      end
    end
  end

  namespace :public do
    task :setup do
      on roles :app do
        within File.join(current_path, fetch(:public)) do
          execute :docker, "create --name #{fetch :public} -v #{File.join(current_path, 'public')}:/home/web/app/public dtheus/rails /bin/true"
        end
      end
    end

    task :clear => :stop do
      on roles :app do
        execute :docker, "rm -f -v #{fetch :public} || true"
      end
    end

    task :start do
      on roles :app do
        execute :docker, "start #{fetch :public}"
      end
    end

    task :stop do
      on roles :app do
        execute %Q(
        if [ $(docker ps --filter="name=#{fetch :public}" -q) ]
          then docker stop #{fetch :public}
        fi)
      end
    end
  end

  namespace :uploads do
    task :start do
      on roles :app do
        execute :docker, "start #{fetch :uploads}"
      end
    end

    task :stop do
      on roles :app do
        execute %Q(
        if [ $(docker ps --filter="name=#{fetch :uploads}" -q) ]
          then docker stop #{fetch :uploads}
        fi)
      end
    end
  end

  namespace :db do
    task :start do
      on roles :app do
        execute :docker, "start #{fetch :db}"
      end
    end

    task :stop do
      on roles :app do
        execute %Q(
        if [ $(docker ps --filter="name=#{fetch :db}" -q) ]
          then docker stop #{fetch :db}
        fi)
      end
    end
  end
end
