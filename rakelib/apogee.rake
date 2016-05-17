# Apogee tasks

APOGEE_INSTALLER_PKG_NAME = 'Duet Software Installer'
APOGEE_PKG_ID = 'com.apogee'
APOGEE_UNINSTALLER_APP = 'Duet Uninstaller'
APOGEE_SOURCE_URL = 'http://www.apogeedigital.com/drivers/Duet_June_2015.dmg'

namespace 'apogee' do
  desc 'Install Apogee Duet'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(APOGEE_INSTALLER_PKG_NAME, APOGEE_PKG_ID, APOGEE_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Apogee Duet'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::run(APOGEE_UNINSTALLER_APP, APOGEE_SOURCE_URL)
    end
  end
end
