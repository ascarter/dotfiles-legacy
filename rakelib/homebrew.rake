# Homebrew tasks

if Bootstrap.macosx?
  HOMEBREW_ROOT = '/opt/homebrew'.freeze
  HOMEBREW_TOOLS = %w(awscli bash-completion gist graphviz htop jq memcached ranger redis sqlite3 unar wget).freeze
  HOMEBREW_TAPS = %w(universal-ctags/universal-ctags).freeze
  HOMEBREW_OVERRIDES = %w(ctags).freeze

  namespace 'homebrew' do
    desc 'Install homebrew'
    task :install do
      puts 'Installing homebrew...'
      if File.exist?(HOMEBREW_ROOT)
        warn 'homebrew installed'
      else
        Bootstrap.sudo_mkdir(HOMEBREW_ROOT)
        Bootstrap.sudo_chown(HOMEBREW_ROOT)
        Bootstrap.sudo_chgrp(HOMEBREW_ROOT, 'admin')
        Bootstrap.sudo_chmod(HOMEBREW_ROOT)

				system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{HOMEBREW_ROOT}"
      end

      Bootstrap::MacOSX.path_helper('homebrew', [File.join(HOMEBREW_ROOT, 'bin')])
      Bootstrap::MacOSX.path_helper('homebrew', [File.join(HOMEBREW_ROOT, 'share', 'man')], 'manpaths')
      Bootstrap::Homebrew.update
    end

    Rake::Task[:install].enhance do
      Rake::Task['homebrew:tools:install'].invoke
    end

    desc 'Update homebrew'
    task :update do
      Bootstrap::Homebrew.update
    end

    desc 'Update homebrew'
    task upgrade: [:update] do
      Bootstrap::Homebrew.upgrade
    end

    desc 'List installed formulae'
    task :list do
      puts Bootstrap::Homebrew.list
    end

    desc 'Uninstall homebrew'
    task uninstall: ['homebrew:tools:uninstall'] do
			system %(ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)")
      %w(paths manpaths).each { |t| Bootstrap::MacOSX.rm_path_helper('homebrew', t) }
      Bootstrap.sudo_rmdir HOMEBREW_ROOT
    end

    namespace 'tools' do
      desc 'Install tools'
      task :install do
        # Install tools from homebrew
        HOMEBREW_TOOLS.each { |p| Bootstrap::Homebrew.install(p) }

        # Install taps
        HOMEBREW_TAPS.each do |p|
          parts = p.split('/')
          Bootstrap::Homebrew.tap("#{parts[0]}/#{parts[1]}")
          Bootstrap::Homebrew.install(parts[1], '--HEAD')
        end

        # Symlink homebrew overrides to /usr/local
        HOMEBREW_OVERRIDES.each { |p| Bootstrap.usr_bin_ln(Bootstrap::Homebrew.bin_path(p), p) }
      end

      desc 'Uninstall tools'
      task :uninstall do
      	if File.exist?(File.join(HOMEBREW_ROOT, 'bin', 'brew'))
					HOMEBREW_TOOLS.each { |p| Bootstrap::Homebrew.uninstall(p) }
					HOMEBREW_TAPS.each { |p| Bootstrap::Homebrew.untap(p) }
					HOMEBREW_OVERRIDES.each { |p| Bootstrap.usr_bin_rm(p) }
				end
      end
    end
  end
end
