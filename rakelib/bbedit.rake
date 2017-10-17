# BBEdit tasks

if Bootstrap.macosx?
  BBEDIT_APP_NAME = 'BBEdit'.freeze
  BBEDIT_SOURCE_URL = 'https://s3.amazonaws.com/BBSW-download/BBEdit-12.0.1_400003.dmg'.freeze 
  # BBEDIT_SIGNATURE_SHA256 = { sha256: '5edd44a1f201f74a7630bdac1e5473027bd94300bbd15ee4471da3d24ba8b0a7' }.freeze

  BBEDIT_AUTOMATOR_PKG_NAME = 'BBEditAutomatorActionsInstaller-11.5'.freeze
  BBEDIT_AUTOMATOR_PKG_ID = '.automatorActions'.freeze
  BBEDIT_AUTOMATOR_SOURCE_URL = 'http://pine.barebones.com/files/BBEdit11.5AutomatorActionsInstaller.zip'.freeze

  BBEDIT_TOOLS = %w(bbdiff bbedit bbfind bbresults).freeze

  BBEDIT_INSTALL_TOOLS_SCPT = 'Resources/BBEdit.help/Contents/Resources/en.lproj/install_tools.scpt'.freeze

  namespace 'bbedit' do
    desc 'Install BBEdit'
    task :install do
      Bootstrap::MacOSX::App.install(BBEDIT_APP_NAME, BBEDIT_SOURCE_URL) #, sig: BBEDIT_SIGNATURE_SHA256)

      # TODO: Set license key

      # Install command line utils
      unless File.exist?('/usr/local/bin/bbedit')
        helper = File.join(Boostrap::MacOSX::App.contents(BBEDIT_APP_NAME), BBEDIT_INSTALL_TOOLS_SCPT)
        Bootstrap::MacOSX.run_applescript(helper, wait: true)
      end

      # Install automator actions
      Bootstrap::MacOSX::Pkg.install(BBEDIT_AUTOMATOR_PKG_NAME,
                                     BBEDIT_AUTOMATOR_PKG_ID,
                                     BBEDIT_AUTOMATOR_SOURCE_URL)

      # Remove outdated update default setting
      Bootstrap::MacOSX::Defaults.delete 'com.barebones.bbedit', :key => 'SUFeedURL'

      # Set preference to treat Open File by Name as modal
      Bootstrap::MacOSX::Defaults.write 'com.barebones.bbedit', 'CloseOFBNWindowAfterOpeningSelection', 'YES', '-bool'

      puts `bbedit --version`
    end

    desc 'Uninstall BBEdit'
    task :uninstall do
      if Bootstrap.usr_bin_exists?('bbedit')
        # Command line tools
        BBEDIT_TOOLS.each do |t|
          Bootstrap.usr_bin_rm(t)
          Bootstrap.sudo_rm(File.join('/usr/local/share/man/man1', "#{t}.1"))
        end
      end

      # Automator actions
      Bootstrap::MacOSX::Pkg.uninstall(BBEDIT_AUTOMATOR_PKG_ID)

      # Remove application
      Bootstrap::MacOSX::App.uninstall('BBEdit')
    end
  end
end
