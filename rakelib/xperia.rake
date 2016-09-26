# xperia tasks

XPERIA_APP_NAME = 'Xperia Companion'.freeze
XPERIA_SOURCE_URL = 'http://www-support-downloads.sonymobile.com/Software%20Downloads/Xperia%20Companion/XperiaCompanion.dmg'.freeze

namespace 'xperia' do
  desc 'Install xperia'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(XPERIA_APP_NAME, XPERIA_SOURCE_URL)
    end
  end

  desc 'Uninstall xperia'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(XPERIA_APP_NAME)
    end
  end
end
