# GitHub tasks

namespace 'github' do
  GITHUB_TOOLS = %w(gist hub).freeze

  desc 'Install GitHub tools and apps'
  task install: ['tools:install', 'desktop:install', 'tower:install']

  desc 'Uninstall GitHub tools and apps'
  task uninstall: ['tools:uninstall', 'dekstop:uninstall', 'tower:uninstall']

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
    GITHUB_DESKTOP_APP = 'Github Desktop'.freeze
    GITHUB_DESKTOP_SRC_URL = 'https://central.github.com/mac/latest'.freeze

    desc 'Install GitHub Desktop'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(GITHUB_DESKTOP_APP,
                                       GITHUB_DESKTOP_SRC_URL)
      end
    end

    desc 'Uninstall GitHub Desktop'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(GITHUB_DESKTOP_APP)
      end
    end
  end

  if Bootstrap.macosx?
    TOWER_APP = 'Tower'.freeze
    TOWER_SRC_URL = 'https://updates.fournova.com/tower2-mac/stable/releases/latest/download'.freeze

    namespace 'tower' do
      desc 'Install Tower'
      task :install do
        Bootstrap::MacOSX::App.install(TOWER_APP, TOWER_SRC_URL)
      end

      desc 'Uninstall Tower'
      task :uninstall do
        Bootstrap::MacOSX::App.uninstall(TOWER_APP)
      end
    end

    namespace 'gitx' do
      GITX_APP = 'GitX'.freeze
      GITX_SRC_URL = 'http://builds.phere.net/GitX/development/GitX-dev.dmg'.freeze

      desc 'Install GitX'
      task :install do
        case RUBY_PLATFORM
        when /darwin/
          Bootstrap::MacOSX::App.install(GITX_APP, GITX_SRC_URL)
        end
      end

      desc 'Uninstall GitX'
      task :uninstall do
        case RUBY_PLATFORM
        when /darwin/
          Bootstrap::MacOSX::App.uninstall(GITX_APP)
        end
      end
    end
  end
end
