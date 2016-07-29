# Docker tasks

DOCKER_APP_NAME = "Docker"
DOCKER_SOURCE_URL = "https://download.docker.com/mac/stable/Docker.dmg"
DOCKER_SIGNATURE = {sha2: "f170610d95c188dee8433eff33c84696c1c8a39421de548a71a1258a458e1b21"}

KITEMATIC_APP_NAME = "Kitematic (Beta)"
KITEMATIC_SOURCE_URL = "https://download.docker.com/kitematic/Kitematic-Mac.zip"

namespace "docker" do
  desc "Install Docker"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(DOCKER_APP_NAME, DOCKER_SOURCE_URL, sig: DOCKER_SIGNATURE)
    end
  end
  
  desc "Uninstall Docker"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      puts "Use Docker app -> Settings -> Uninstall to remove"
    end
  end
  
  namespace "kitematic" do
    desc "Install Kitematic"
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(KITEMATIC_APP_NAME, KITEMATIC_SOURCE_URL)
      end
    end
    
    desc "Uninstall Kitematic"
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(KITEMATIC_APP_NAME)
      end
    end
  end
end