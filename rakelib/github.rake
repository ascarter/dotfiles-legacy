# GitHub tasks

namespace 'github' do
  GITHUB_TOOLS = %w(gist hub).freeze

  desc 'Install GitHub tools and apps'
  task install: ['tools:install', 'desktop:install', 'tower:install', 'gitx:install']

  desc 'Uninstall GitHub tools and apps'
  task uninstall: ['tools:uninstall', 'dekstop:uninstall', 'tower:uninstall', 'gitx:uninstall']

  namespace 'tools' do
    desc 'Install GitHub tools'
    task :install do
      GITHUB_TOOLS.each { |p| Bootstrap::Homebrew.install(p) }
    end

    desc 'Uninstall GitHub tools'
    task :uninstall_tools do
      GITHUB_TOOLS.each { |p| Bootstrap::Homebrew.uninstall(p) }
    end
  end

  namespace 'desktop' do
    desc 'Install GitHub Desktop'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install('Github Desktop', 'https://central.github.com/mac/latest')
      when /linux/
        warn 'NYI'
      when /windows/
        warn 'NYI'
      else
        raise 'Platform not supported'
      end
    end

    desc 'Uninstall GitHub Desktop'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall('Github Desktop')
      when /linux/
        warn 'NYI'
      when /windows/
        warn 'NYI'
      else
        raise 'Platform not supported'
      end
    end
  end

  if Bootstrap.macosx?
    namespace 'tower' do
      desc 'Install Tower'
      task :install do
        Bootstrap::MacOSX::App.install('Tower', 'https://updates.fournova.com/tower2-mac/stable/releases/latest/download')
      end

      desc 'Uninstall Tower'
      task :uninstall do
        Bootstrap::MacOSX::App.uninstall('Tower')
      end
    end

    namespace 'gitup' do
      desc 'Install GitUp'
      task :install do
        Bootstrap::MacOSX::App.install('GitUp', 'https://s3-us-west-2.amazonaws.com/gitup-builds/stable/GitUp.zip')
      end

      desc 'Uninstall GitUp'
      task :uninstall do
        Bootstrap.usr_bin_rm('gitup')
        Bootstrap::MacOSX::App.uninstall('GitUp')
      end
    end
  end

  namespace 'gitx' do
    desc 'Install GitX'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install('GitX', 'http://builds.phere.net/GitX/development/GitX-dev.dmg')
      else
        warn 'Platform not supported'
      end
    end

    desc 'Uninstall GitX'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall('GitX')
      else
        warn 'Platform not supported'
      end
    end
  end
end
