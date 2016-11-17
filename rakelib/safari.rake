# Safari tasks

if Bootstrap.macosx?
  SAFARI_APP_NAME = 'Safari Technology Preview'.freeze
  SAFARI_PKG_ID = 'com.apple.pkg.SafariTechPreview'.freeze
  SAFARI_PKG_NAME = 'Safari Technology Preview'.freeze
  SAFARI_SOURCE_URL = 'https://secure-appldnld.apple.com/STP/031-91487-2016111-55B288AC-CBDD-4422-815E-CEEA2C345EE7/SafariTechnologyPreview.dmg'.freeze

  namespace 'safari' do
    desc 'Install Safari Developer Preview'
    task :install do
      if Bootstrap::MacOSX::App.exists?(SAFARI_APP_NAME)
        warn "#{SAFARI_APP_NAME} already installed"
      else
        Bootstrap::MacOSX::Pkg.install(SAFARI_PKG_NAME, SAFARI_PKG_ID, SAFARI_SOURCE_URL)
      end
    end

    desc 'Uninstall Safari Developer Preview'
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(SAFARI_APP_NAME)
    end
  end
end
