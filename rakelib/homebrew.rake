# Homebrew tasks

if Bootstrap.macosx?
  HOMEBREW_ROOT = '/opt/homebrew'
  HOMEBREW_TOOLS = %w(awscli bash-completion gist graphviz jq memcached protobuf redis unar wget)
  HOMEBREW_TAPS = %w(universal-ctags/universal-ctags)
  HOMEBREW_OVERRIDES = %w(ctags)

  namespace "homebrew" do  
    desc "Install homebrew"
    task :install do
      puts "Installing homebrew..."
      unless File.exist?(HOMEBREW_ROOT)
        Bootstrap.sudo_mkdir(HOMEBREW_ROOT)
        Bootstrap.sudo_chgrp(HOMEBREW_ROOT, 'admin')
        Bootstrap.sudo_chmod(HOMEBREW_ROOT)
        system "curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C #{homebrew_root}"
      else
        warn "homebrew installed"
      end
    
      Bootstrap::MacOSX.path_helper('homebrew', [File.join(HOMEBREW_ROOT, 'bin')])
      Bootstrap::MacOSX.path_helper('homebrew', [File.join(HOMEBREW_ROOT, 'share', 'man')], 'manpaths')    
      Bootstrap::Homebrew.update
    end
    
    Rake::Task[:install].enhance do
      Rake::Task['homebrew:tools:install'].invoke
    end
  
    desc "Update homebrew"
    task :update do
      Bootstrap::Homebrew.update
    end
  
    desc "Update homebrew"
    task :upgrade => [ :update ] do
      Bootstrap::Homebrew.upgrade
    end
  
    desc "List installed formulae"
    task :list do
      puts Bootstrap::Homebrew.list
    end
    
    desc "Uninstall homebrew"
    task :uninstall => ['homebrew:tools:uninstall'] do
      Bootstrap.sudo_rmdir homebrew_root
      %w{paths manpaths}.each { |t| Bootstrap::MacOSX.rm_path_helper('homebrew', t) } 
      installed_dirs = [
        '~/Library/Caches/Homebrew',
        '~/Library/Logs/Homebrew',
        '/Library/Caches/Homebrew'
      ]
      installed_dirs.each { |d| Bootstrap.sudo_rmdir d }
    end

    namespace "tools" do
      desc "Install tools"
      task :install do
        # Install tools from homebrew
        HOMEBREW_TOOLS.each { |p| Bootstrap::Homebrew.install(p) }
    
        # Install taps
        HOMEBREW_TAPS.each do |p|
          parts = p.split("/")
          Bootstrap::Homebrew.tap("#{parts[0]}/#{parts[1]}")
          Bootstrap::Homebrew.install(parts[1], "--HEAD")
        end
    
        # Symlink homebrew overrides to /usr/local
        HOMEBREW_OVERRIDES.each { |p| Bootstrap.usr_bin_ln(Bootstrap::Homebrew.bin_path(p), p) }
      end

      desc "Uninstall tools"
      task :uninstall do
        HOMEBREW_TOOLS.each { |p| Bootstrap::Homebrew.uninstall(p) }
        HOMEBREW_TAPS.each { |p| Bootstrap::Homebrew.untap(p) }
        HOMEBREW_OVERRIDES.each { |p| Bootstrap.usr_bin_rm(p) }
      end
    end
  end
end
