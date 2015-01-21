# Vim tasks

namespace "vim" do
  desc "Install vim support"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install MacVim      
      unless File.exist?('/Applications/MacVim.app')
        snapshot = 'snapshot-73'
        snapshot_pkg = "MacVim-#{snapshot}-Mavericks.tbz"
        snapshot_url = "https://github.com/b4winckler/macvim/releases/download/#{snapshot}/#{snapshot_pkg}"
        pkg_download(snapshot_url) do |p|
          tmp_dir = File.dirname(p)
          tmp_src = File.join(tmp_dir, "MacVim-#{snapshot}")
          sh "cd #{tmp_dir} && tar xvzf #{File.basename(p)}"
          install_app(File.join(tmp_src, 'MacVim.app'))
          sudo "mv #{File.join(tmp_src, 'mvim')} /usr/local/bin/."
        end
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
      sudo_remove_dir(macvim_path)
    end
  end
end
