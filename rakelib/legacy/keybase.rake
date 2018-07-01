# Keybase tasks

KEYBASE_APP_NAME = 'Keybase'.freeze
KEYBASE_SOURCE_URL = 'https://prerelease.keybase.io/Keybase.dmg'.freeze

namespace 'keybase' do
  desc 'Install Keybase'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.install(KEYBASE_APP_NAME, KEYBASE_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Keybase'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.uninstall(KEYBASE_APP_NAME)
    end
  end 
end
