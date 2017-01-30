# etcher tasks

ETCHER_APP_NAME = 'Etcher'.freeze
ETCHER_SOURCE_URL = 'https://resin-production-downloads.s3.amazonaws.com/etcher/1.0.0-beta.18/Etcher-1.0.0-beta.18-darwin-x64.dmg'.freeze

namespace 'etcher' do
  desc 'Install etcher'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ETCHER_APP_NAME, ETCHER_SOURCE_URL)
    end
  end

  desc 'Uninstall etcher'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ETCHER_APP_NAME)
    end
  end
end
