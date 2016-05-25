# Docker tasks

DOCKER_APP_NAME = 'Docker'
DOCKER_SOURCE_URL = 'https://dyhfha9j6srsj.cloudfront.net/Docker.dmg'

namespace "docker" do
  desc "Install Docker"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(DOCKER_APP_NAME, DOCKER_SOURCE_URL)
    end
  end
  
  desc "Uninstall Docker"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      puts 'Use Docker app -> Settings -> Uninstall to remove'
    end
  end
end