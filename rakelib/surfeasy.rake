# SurfEasy VPN tasks

SURFEASY_APP_NAME = 'SurfEasy VPN'.freeze
SURFEASY_SOURCE_URL = 'https://accounts.surfeasy.com/downloads/surfeasyvpn/macinstaller'.freeze

namespace 'surfeasy' do
  desc 'Install surfeasy'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SURFEASY_APP_NAME, SURFEASY_SOURCE_URL)
    end
  end

  desc 'Uninstall surfeasy'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SURFEASY_APP_NAME)
    end
  end
end
