# rbenv tasks

namespace 'rbenv' do
  desc 'Install rbenv'
  task :install do
    rbenv_root = File.expand_path(File.join(Bootstrap.home_dir, '.rbenv'))

    plugins = [
      { owner: 'rbenv', repo: 'ruby-build' },
      { owner: 'rbenv', repo: 'rbenv-vars' },
      { owner: 'rbenv', repo: 'rbenv-each' },
      { owner: 'rbenv', repo: 'rbenv-default-gems' },
      { owner: 'tpope', repo: 'rbenv-ctags' },
      { owner: 'rkh',   repo: 'rbenv-update' },
      { owner: 'rkh',   repo: 'rbenv-whatis' },
      { owner: 'rkh',   repo: 'rbenv-use' }
    ]

    if File.exist?(rbenv_root)
      warn 'rbenv already installed'
    else
      puts 'Installing rbenv...'
      Bootstrap::Git.clone('rbenv/rbenv', rbenv_root)
      system("cd #{rbenv_root} && src/configure && make -C src")
    end

    plugins.each do |item|
      owner = item[:owner]
      repo = item[:repo]
      dest = File.join(rbenv_root, 'plugins', repo)
      if File.exist?(dest)
        warn "Plugin #{owner}/#{repo} already installed"
      else
        Bootstrap::Git.clone("#{owner}/#{repo}", dest)
      end
    end

    default_gem_file = File.join(rbenv_root, 'default-gems')
    default_gems = %w(gem-ctags bundler)
    if File.exist?(default_gem_file)
      warn "#{default_gem_file} already exists"
    else
      puts "Creating #{default_gem_file}"
      File.open(default_gem_file, 'w') do |file|
        default_gems.each { |g| file.puts g }
      end
    end
  end

  desc 'Update rbenv'
  task :update do
    puts 'Updating rbenv...'
    system('rbenv update')
  end

  desc 'Uninstall rbenv'
  task :uninstall do
    puts 'Uninstalling rbenv...'
    rbenv_root = File.expand_path(File.join(ENV['HOME'], '.rbenv'))
    Bootstrap.file_remove(rbenv_root)
  end
end
