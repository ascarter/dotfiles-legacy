# rbenv tasks

namespace "rbenv" do
  desc "Install rbenv"
  task :install do
    puts "Installing rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.rbenv')))
    plugins = %w{ruby-build rbenv-vars rbenv-gem-rehash rbenv-default-gems}

    unless File.exist?(rbenv_root.to_s)
      git_clone('sstephenson', 'rbenv', rbenv_root)
      plugins.each do |plugin|
        git_clone('sstephenson', plugin, rbenv_root.join('plugins', plugin))
      end
    else
      puts "Updating rbenv..."
      system "cd #{rbenv_root} && git pull"
      plugins.each do |plugin|
        puts "Updating #{plugin}..."
        system "cd #{rbenv_root}/plugins/#{plugin} && git pull"
      end
    end
  end

  desc "Uninstall rbenv"
  task :uninstall do
    puts "Uninstalling rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.rbenv')))
    file_remove(rbenv_root)
  end
end
