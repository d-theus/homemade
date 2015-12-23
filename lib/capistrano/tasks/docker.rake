namespace :docker do
  task :clear => %w(proxy:clear servers:clear)
  task :setup => %w(servers:setup proxy:setup)
  task :restart => %w(proxy:stop servers:stop servers:start proxy:start)

  namespace :servers do
    task :setup do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute "docker run --name #{fetch :rails_image}#{i} -d --volumes-from #{fetch :uploads_container} --link #{fetch :pg_container} #{fetch :rails_image}"
        end
      end
    end

    task :clear do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute "docker rm #{fetch :rails_image}#{i} || /bin/true"
        end
      end
    end

    task :start do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute "docker start #{fetch :rails_image}#{i}"
        end
      end
    end

    task :stop do
      on roles :app do
        for i in 1..fetch(:backends_count)
          execute "docker stop #{fetch :rails_image}#{i}"
        end
      end
    end
  end

  namespace :proxy do
    task :setup do
      on roles :app do
        execute "docker run -d #{fetch :proxy_links} #{fetch :nginx_image}"
      end
    end

    task :clear do
      on roles :app do
        execute "docker rm #{fetch :nginx_image} || /bin/true"
      end
    end

    task :start do
      on roles :app do
        execute "docker start #{fetch :nginx_image}"
      end
    end

    task :stop do
      on roles :app do
        execute "docker stop #{fetch :nginx_image}"
      end
    end
  end
end

