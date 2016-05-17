# Backblaze tasks

BACKBLAZE_INSTALLER_APP = 'Backblaze Installer'
BACKBLAZE_UNINSTALLER_APP = 'Backblaze Uninstaller'
BACKBLAZE_SOURCE_URL = 'https://secure.backblaze.com/mac/install_backblaze.dmg'

namespace 'backblaze' do
  desc 'Install Backblaze'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.run(BACKBLAZE_INSTALLER_APP, BACKBLAZE_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Backblaze'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::run(BACKBLAZE_UNINSTALLER_APP, BACKBLAZE_SOURCE_URL)
    end
  end
end
