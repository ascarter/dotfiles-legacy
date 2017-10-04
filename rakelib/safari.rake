# Safari tasks

if Bootstrap.macosx?
  SAFARI_APP_NAME = 'Safari Technology Preview'.freeze
  SAFARI_PKG_ID = 'com.apple.pkg.SafariTechPreview'.freeze
  SAFARI_PKG_NAME = 'Safari Technology Preview'.freeze
  SAFARI_SOURCE_URL = 'https://secure-appldnld.apple.com/STP/091-34342-20171004-850AA9D4-A833-11E7-AD5B-B81DCB2232C2/SafariTechnologyPreview.dmg'.freeze

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
