# rbenv tasks

namespace "rbenv" do
  desc "Install rbenv"
  task :install do
    puts "Installing rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(Bootstrap.home_dir(), '.rbenv')))
    
    plugins = [
      { owner: "sstephenson", repo: "ruby-build" },
      { owner: "sstephenson", repo: "rbenv-vars" },
      { owner: "sstephenson", repo: "rbenv-gem-rehash" },
      { owner: "sstephenson", repo: "rbenv-default-gems" },
      { owner: "parkr",       repo: "ruby-build-github" },
      { owner: "tpope",       repo: "rbenv-ctags" },
    ]

    unless File.exist?(rbenv_root.to_s)
      Bootstrap::Git.clone('sstephenson/rbenv', rbenv_root)
    else
      puts "Updating rbenv..."
      Bootstrap::Git.pull(rbenv_root)
    end

    plugins.each do |item|
      owner = item[:owner]
      repo = item[:repo]
      dest = rbenv_root.join('plugins', repo)
      unless File.exist?(dest)
        Bootstrap::Git.clone("#{owner}/#{repo}", dest)
      else
        puts "Updating #{repo}..."
        Bootstrap::Git.pull(dest)
      end
    end
  end

  desc "Uninstall rbenv"
  task :uninstall do
    puts "Uninstalling rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.rbenv')))
    Bootstrap.file_remove(rbenv_root)
  end
end
