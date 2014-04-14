# Homebrew tasks

namespace "homebrew" do  
  desc "Install homebrew"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      puts "Installing homebrew..."
      homebrew_root = '/opt/homebrew'
      unless File.exist?(homebrew_root)
        sudo "mkdir -p #{homebrew_root}"
        sudo "curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C #{homebrew_root}"
      end
      path_helper('homebrew', ['/opt/homebrew/bin'])
      path_helper('homebrew', ['/opt/homebrew/share/man'], 'manpaths')
      sudo "/opt/homebrew/bin/brew update"
      zsh_completion_source = File.join(homebrew_root, 'Library/Contributions/brew_zsh_completion.zsh')
      zsh_local = File.expand_path(File.join(ENV['HOME'], '.zsh_local/functions'))
      zsh_completion_target = File.expand_path(File.join(zsh_local, '_brew'))
      if File.exist?(zsh_completion_source) and File.exist?(zsh_local)
        link_file(zsh_completion_source, zsh_completion_target)
      end
    else
      puts "Homebrew not supported on #{RUBY_PLATFORM}"
    end
  end

  desc "Uninstall homebrew"
  task :uninstall do
    homebrew_root = '/opt/homebrew'
    #if File.exist?(homebrew_root)
      installed_files = [
        '~/Library/Caches/Homebrew',
        '~/Library/Logs/Homebrew',
        '/Library/Caches/Homebrew',
        '/etc/paths.d/homebrew',
        '/etc/manpaths.d/homebrew'
      ]
      sudo "rm -rf #{homebrew_root}"
      sudo "rm -rf #{installed_files.join(' ')}"
    #end
  end
end

