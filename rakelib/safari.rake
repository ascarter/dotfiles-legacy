# Safari tasks

if Bootstrap.macosx?
  SAFARI_APP_NAME = 'Safari Technology Preview'
  SAFARI_PKG_ID = 'com.apple.pkg.SafariTechPreviewElCapitan'
  SAFARI_PKG_NAME = 'Safari Technology Preview'
  SAFARI_SOURCE_URL = 'http://appldnld.apple.com/STP/SafariTechnologyPreview.dmg'

  namespace 'safari' do
    desc 'Install Safari Developer Preview'
    task :install do
      unless Bootstrap::MacOSX::App.exists?(SAFARI_APP_NAME)
        Bootstrap::MacOSX::Pkg.install(SAFARI_PKG_NAME, SAFARI_PKG_ID, SAFARI_SOURCE_URL)
      else
        warn "#{SAFARI_APP_NAME} already installed"
      end
    end
  
    desc "Uninstall Safari Developer Preview"
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(SAFARI_APP_NAME)
    end
  end
end
