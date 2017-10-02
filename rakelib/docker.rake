# Docker tasks

DOCKER_APP_NAME = 'Docker'.freeze
DOCKER_SOURCE_URL = 'https://download.docker.com/mac/stable/Docker.dmg'.freeze
DOCKER_SHA256SUM = 'https://download.docker.com/mac/stable/Docker.dmg.sha256sum'.freeze

DOCKER_BETA_SOURCE_URL = 'https://download.docker.com/mac/edge/Docker.dmg'.freeze
DOCKER_BETA_SHA256SUM = 'https://download.docker.com/mac/edge/Docker.dmg.sha256sum'.freeze

KITEMATIC_APP_NAME = 'Kitematic (Beta)'.freeze
KITEMATIC_SOURCE_URL = 'https://download.docker.com/kitematic/Kitematic-Mac.zip'.freeze

namespace 'docker' do
  desc 'Install Docker'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(DOCKER_APP_NAME, DOCKER_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Docker'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      sh "/Applications/Docker.app/Contents/MacOS/Docker --uninstall"
      Bootstrap::MacOSX::App.uninstall(DOCKER_APP_NAME)
    end
  end

  namespace 'beta' do
    desc 'Install Docker Beta'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(DOCKER_APP_NAME, DOCKER_BETA_SOURCE_URL)
      end
    end
  end
  
  namespace 'kitematic' do
    desc 'Install Kitematic'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(KITEMATIC_APP_NAME, KITEMATIC_SOURCE_URL)
      end
    end

    desc 'Uninstall Kitematic'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(KITEMATIC_APP_NAME)
      end
    end
  end
end
