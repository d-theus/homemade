role :app, Dir.chdir(fetch :chef_dir) { `ls nodes` }.lines.grep(/^(\d+\.\d+\.\d+\.\d+)\.json/).map {|f| File.basename(f, File.extname(f)) }

set :ssh_options, {
  user: 'web'
}
