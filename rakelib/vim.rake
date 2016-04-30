# Vim tasks

namespace "vim" do
  desc "Install vim"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install MacVim
      unless File.exist?('/Applications/MacVim.app')
        snapshot = 'snapshot-101'
        snapshot_dmg = "MacVim.dmg"
        snapshot_url = "https://github.com/macvim-dev/macvim/releases/download/#{snapshot}/#{snapshot_dmg}"
        pkg_download(snapshot_url) do |p|
          dmg_mount(p) do |d|
            app_install(File.join(d, "MacVim.app"))
            sudo "cp \"#{File.join(d, 'mvim')}\" /usr/local/bin/."
          end
        end
      else
        puts "MacVim already installed"
      end

      # Symlink vim programs to mvim on mac
      mvim = '/usr/local/bin/mvim'
      if File.exist?(mvim)
        # Gui, Diff, Read-only, Ex, Restricted
        %w(gvim mvimdiff mview mex rmvim vim).each { |p| usr_bin_ln(mvim, p) }
      end
    end
    
    user_vim_path = File.expand_path(File.join(home_dir(), '.vim'))
    mkdir(user_vim_path) unless File.exist?(user_vim_path)
    
    puts %x{vim --version}
  end

  Rake::Task["vim:install"].enhance do
    Rake::Task["vim:vundle"].invoke
  end

  desc "Update vundle"
  task :vundle do
    vundle_path = File.expand_path(File.join(home_dir(), '.vim/bundle/vundle'))
    unless File.exist?(vundle_path)
      git_clone('gmarik/vundle', vundle_path)
      system "vim +PluginInstall +qall"
    else
      puts "Update vundle"
      git_pull(vundle_path)
      system "vim +PluginInstall +qall"
    end
  end

  desc "Uninstall vim"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      # Remove symlinks
      %w(gvim mvimdiff mview mex rmvim vim).each { |p| usr_bin_rm(p) }

      # Remove bundles
      bundle_path = File.expand_path(File.join(home_dir(), '.vim/bundle'))
      if File.exist?(bundle_path)
        file_remove(bundle_path)
      end

      # Remove MacVim
      app_remove("MacVim")
    end
  end
  
  desc "Update vim"
  task update: [:uninstall, :install]
end
