# spectacle tasks

SPECTACLE_APP_NAME = 'Spectacle'.freeze
SPECTACLE_SOURCE_URL = 'https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip'.freeze

namespace 'spectacle' do
  desc 'Install Spectacle'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SPECTACLE_APP_NAME, SPECTACLE_SOURCE_URL)
    end
  end

  desc 'Uninstall Spectacle'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SPECTACLE_APP_NAME)
    end
  end
end
