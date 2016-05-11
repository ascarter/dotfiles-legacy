# Homebrew tasks

if RUBY_PLATFORM =~ /darwin/
  namespace "homebrew" do  
    desc "Install homebrew"
    task :install do
      puts "Installing homebrew..."
      homebrew_root = '/opt/homebrew'
      unless File.exist?(homebrew_root)
        FileTools.sudo_mkdir homebrew_root
        FileTools.sudo_chgrp homebrew_root
        FileTools.sudo_chmod homebrew_root
        system "curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C #{homebrew_root}"
      else
        warn "homebrew installed"
      end
    
      MacOSX.path_helper('homebrew', ['/opt/homebrew/bin'])
      MacOSX.path_helper('homebrew', ['/opt/homebrew/share/man'], 'manpaths')
    
      HomeBrew.update
    end
  
    desc "Update homebrew"
    task :update do
      HomeBrew.update
    end
  
    desc "List installed formulae"
    task :list do
      puts HomeBrew.list
    end
    
    desc "Uninstall homebrew"
    task :uninstall do
      installed_dirs = [
        '~/Library/Caches/Homebrew',
        '~/Library/Logs/Homebrew',
        '/Library/Caches/Homebrew'
      ]
      installed_files = [
        '/etc/paths.d/homebrew',
        '/etc/manpaths.d/homebrew'
      ]
      homebrew_root = '/opt/homebrew'
      FileTools.sudo_rmdir homebrew_root
      installed_dirs.each { |d| FileTools.sudo_rmdir d }
      installed_files.each { |f| FileTools.sudo_rm f }
    end

    # Tools from homebrew
    brew_tools = %w(bash-completion gist graphviz jq memcached protobuf redis unar wget)
    brew_taps = %w(universal-ctags/universal-ctags)
    brew_overrides = %w(ctags)

    namespace "tools" do
      desc "Install tools"
      task :install do
        # Install tools from homebrew
        brew_tools.each { |p| HomeBrew.install(p) }
    
        # Install taps
        brew_taps.each do |p|
          parts = p.split("/")
          HomeBrew.tap("#{parts[0]}/#{parts[1]}")
          HomeBrew.install(parts[1], "--HEAD")
        end
    
        # Symlink homebrew overrides to /usr/local
        brew_overrides.each { |p| FileTools.usr_bin_ln(HomeBrew.bin_path(p), p) }
      end

      desc "Uninstall tools"
      task :uninstall do
        brew_tools.each { |p| HomeBrew.uninstall(p) }
        brew_taps.each { |p| HomeBrew.untap(p) }
        brew_overrides.each { |p| FileTools.usr_bin_rm(p) }
      end
    end
  end
else
  warn "Homebrew not supported on #{RUBY_PLATFORM}"
end
