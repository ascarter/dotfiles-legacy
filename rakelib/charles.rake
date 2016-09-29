# charles tasks

CHARLES_APP_NAME = 'Charles'.freeze
CHARLES_SOURCE_URL = 'https://www.charlesproxy.com/assets/release/4.0.1/charles-proxy-4.0.1.dmg'.freeze

namespace 'charles' do
  desc 'Install charles'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(CHARLES_APP_NAME, CHARLES_SOURCE_URL)
    end
  end

  desc 'Uninstall charles'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(CHARLES_APP_NAME)
    end
  end
end
