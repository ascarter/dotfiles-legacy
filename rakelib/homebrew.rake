# Homebrew tasks

namespace "homebrew" do  
  desc "Install homebrew"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      puts "Installing homebrew..."
      homebrew_root = '/opt/homebrew'
      unless File.exist?(homebrew_root)
        sudo "mkdir -p #{homebrew_root}"
        sudo "chgrp -R admin #{homebrew_root}"
        sudo "chmod g+w #{homebrew_root}"
        system "curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C #{homebrew_root}"
      end
      path_helper('homebrew', ['/opt/homebrew/bin'])
      path_helper('homebrew', ['/opt/homebrew/share/man'], 'manpaths')
      system "/opt/homebrew/bin/brew update"
      
      zsh_local = File.expand_path('~/.zsh_local')
      zsh_local_fn = File.join(zsh_local, 'functions')
      zsh_brew_completion = File.join(zsh_local_fn, '_brew')
      unless File.exist?(zsh_brew_completion)
        FileUtils.mkdir_p(zsh_local_fn)
        link_file(File.join(homebrew_root, 'Library', 'Contributions', 'brew_zsh_completion.zsh'), zsh_brew_completion)
      end
    else
      puts "Homebrew not supported on #{RUBY_PLATFORM}"
    end
  end
  
  desc "Update homebrew"
  task :update do
    if RUBY_PLATFORM =~ /darwin/
      brew_update
    else
      puts "Homebrew not supported on #{RUBY_PLATFORM}"
    end
  end
  
  desc "Uninstall homebrew"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      installed_files = [
        '~/Library/Caches/Homebrew',
        '~/Library/Logs/Homebrew',
        '/Library/Caches/Homebrew',
        '/etc/paths.d/homebrew',
        '/etc/manpaths.d/homebrew'
      ]
      homebrew_root = '/opt/homebrew'
      sudo "rm -rf #{homebrew_root}"
      sudo "rm -rf #{installed_files.join(' ')}"
    else
      puts "Homebrew not supported on #{RUBY_PLATFORM}"
    end
  end
end

