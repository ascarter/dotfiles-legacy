# Garmin

GARMIN_PKG_NAME = 'Install Garmin Express'.freeze
GARMIN_PKG_ID = 'com.garmin.renu.client'.freeze
GARMIN_SOURCE_URL = 'http://download.garmin.com/omt/express/B/GarminExpressInstaller.dmg'.freeze

namespace 'garmin' do
  desc 'Install Garmin Express'
  task :install do
    Bootstrap::MacOSX::Pkg.install(GARMIN_PKG_NAME, GARMIN_PKG_ID, GARMIN_SOURCE_URL)
  end

  desc 'Uninstall Garmin Express'
  task :uninstall do
    Bootstrap::MacOSX::Pkg.uninstall(GARMIN_PKG_ID)
  end
end
