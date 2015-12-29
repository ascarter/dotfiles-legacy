# Vim tasks

namespace "vim" do
  desc "Install vim"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install MacVim
      unless File.exist?('/Applications/MacVim.app')
        snapshot = 'snapshot-88'
        snapshot_dmg = "MacVim-7.4.dmg"
        snapshot_url = "https://github.com/macvim-dev/macvim/releases/download/#{snapshot}/#{snapshot_dmg}"
        pkg_download(snapshot_url) do |p|
          src = dmg_mount(p)
          app_install(File.join(src, "MacVim.app"))
          sudo "cp \"#{File.join(src, 'mvim')}\" /usr/local/bin/."
          dmg_unmount(src)
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
      sh "vim +PluginInstall +qall"
    else
      puts "Update vundle"
      git_pull(vundle_path)
      sh "vim +PluginInstall +qall"
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
