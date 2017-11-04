# Riot tasks

RIOT_APP_NAME = 'Riot'.freeze
RIOT_SOURCE_URL = 'https://riot.im/download/desktop/install/macos/Riot-0.12.7.dmg'.freeze

namespace 'riot' do
  desc 'Install Riot'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(RIOT_APP_NAME, RIOT_SOURCE_URL)
    end
  end

  desc 'Uninstall Riot'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(RIOT_APP_NAME)
    end
  end
end
