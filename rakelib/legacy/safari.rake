# Safari tasks

if Bootstrap.macOS?
  SAFARI_APP_NAME = 'Safari Technology Preview'.freeze
  SAFARI_PKG_ID = 'com.apple.pkg.SafariTechPreview'.freeze
  SAFARI_PKG_NAME = 'Safari Technology Preview'.freeze
  SAFARI_SOURCE_URL = 'https://secure-appldnld.apple.com/STP/091-47387-20171115-0BCEE496-C97A-11E7-B266-7FC0A61DC569/SafariTechnologyPreview.dmg'.freeze

  namespace 'safari' do
    desc 'Install Safari Developer Preview'
    task :install do
      if MacOS::App.exists?(SAFARI_APP_NAME)
        warn "#{SAFARI_APP_NAME} already installed"
      else
        MacOS::Pkg.install(SAFARI_PKG_NAME, SAFARI_PKG_ID, SAFARI_SOURCE_URL)
      end
    end

    desc 'Uninstall Safari Developer Preview'
    task :uninstall do
      MacOS::App.uninstall(SAFARI_APP_NAME)
    end
  end
end
