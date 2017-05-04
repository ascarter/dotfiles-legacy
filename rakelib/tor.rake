# Tor tasks

TOR_APP_NAME = 'TorBrowser'.freeze
TOR_SOURCE_URL = 'https://www.torproject.org/dist/torbrowser/6.5.2/TorBrowser-6.5.2-osx64_en-US.dmg'.freeze

namespace 'tor' do
  desc 'Install Tor'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(TOR_APP_NAME, TOR_SOURCE_URL)
    end
  end

  desc 'Uninstall Tor'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(TOR_APP_NAME)
    end
  end
end
