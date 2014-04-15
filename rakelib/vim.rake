# Vim tasks

namespace "vim" do
  desc "Install vim support"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install MacVim      
      unless File.exist?('/Applications/MacVim.app')
        snapshot = 'snapshot-72'
        snapshot_pkg = "MacVim-#{snapshot}-Mavericks.tbz"
        snapshot_url = "https://github.com/b4winckler/macvim/releases/download/#{snapshot}/#{snapshot_pkg}"
        snapshot_pkg_path = File.join('/tmp', snapshot_pkg)
        snapshot_src = File.join('/tmp', "MacVim-#{snapshot}")
        puts "Downloading #{snapshot_url}..."
        download_file(snapshot_url, snapshot_pkg_path)
        cmd = "cd /tmp && tar xvzf #{snapshot_pkg}"
        sh cmd
        cmd = "mv #{snapshot_src}/MacVim.app /Applications/. && mv #{snapshot_src}/mvim /usr/local/bin/."
        sudo cmd
        file_remove(File.join('/tmp', "MacVim-#{snapshot}"))
        file_remove(snapshot_pkg_path)
      else
        puts "MacVim already installed"
      end

      # Symlink vim programs to mvim on mac
      usr_bin = '/usr/local/bin'
      mvim_path = File.join(usr_bin, 'mvim')
      if File.exist?(mvim_path)
        # Gui, Diff, Read-only, Ex, Restricted
        %w(gvim mvimdiff mview mex rmvim vim).each do |prog|
          ln_path = File.join(usr_bin, prog)
          sudo "ln -s #{mvim_path} #{ln_path}" unless File.exist?(ln_path)
        end
      end
    end

    # Vundle install
    vundle_path = File.expand_path(File.join(ENV['HOME'], '.vim/bundle/vundle'))
    unless File.exist?(vundle_path)
      git_clone('gmarik', 'vundle', vundle_path)
      sh "vim +PluginInstall +qall"
    else
      puts "Update vundle"
      git_pull(vundle_path)
      sh "vim +PluginInstall +qall"
    end
  end

  desc "Uninstall vim support"
  task :uninstall do
    usr_bin = '/usr/local/bin'
    mvim_path = File.join(usr_bin, 'mvim')
    if File.exist?(mvim_path)
      # Gui, Diff, Read-only, Ex, Restricted
      %w(gvim mvimdiff mview mex rmvim vim).each do |prog|
        target = File.expand_path(File.join(usr_bin, prog))
        sudo_remove(target)
      end
    end

    bundle_path = File.expand_path(File.join(ENV['HOME'], '.vim/bundle'))
    if File.exist?(bundle_path)
      file_remove(bundle_path)
    end

    macvim_path = '/Applications/MacVim.app'
    if File.exist?(macvim_path)
      sudo_remove(macvim_path)
    end
  end
end
