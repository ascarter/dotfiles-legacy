# BBEdit tasks

if Bootstrap.macosx?
  BBEDIT_APP_NAME = 'BBEdit'.freeze
  BBEDIT_SOURCE_URL = 'https://s3.amazonaws.com/BBSW-download/BBEdit_11.5.2.dmg'.freeze

  BBEDIT_AUTOMATOR_PKG_NAME = 'BBEditAutomatorActionsInstaller-11.5'.freeze
  BBEDIT_AUTOMATOR_PKG_ID = '.automatorActions'.freeze
  BBEDIT_AUTOMATOR_SOURCE_URL = 'http://pine.barebones.com/files/BBEdit11.5AutomatorActionsInstaller.zip'.freeze

  BBEDIT_DEFAULTS_DOMAIN = 'com.barebones.bbedit'.freeze
  BBEDIT_SUFEED_URL = 'http://pine.barebones.com/rhombus/BBEdit.xml'.freeze

  BBEDIT_TOOLS = %w(bbdiff bbedit bbfind bbresults).freeze

  BBEDIT_INSTALL_TOOLS_SCPT = '/Applications/BBEdit.app/Contents/Resources/BBEdit Help/install_tools.scpt'.freeze

  namespace 'bbedit' do
    desc 'Install BBEdit'
    task :install do
      Bootstrap::MacOSX::App.install(BBEDIT_APP_NAME, BBEDIT_SOURCE_URL)

      # TODO: Set license key

      # Install command line utils
      unless File.exist?('/usr/local/bin/bbedit')
        Bootstrap::MacOSX.run_applescript(BBEDIT_INSTALL_TOOLS_SCPT)
      end

      # Install automator actions
      Bootstrap::MacOSX::Pkg.install(BBEDIT_AUTOMATOR_PKG_NAME,
                                     BBEDIT_AUTOMATOR_PKG_ID,
                                     BBEDIT_AUTOMATOR_SOURCE_URL)

      # Set preferences
      Bootstrap::MacOSX::Defaults.write(BBEDIT_DEFAULTS_DOMAIN,
                                        'CloseOFBNWindowAfterOpeningSelection',
                                        'YES',
                                        '-bool')
      Bootstrap::MacOSX::Defaults.write(BBEDIT_DEFAULTS_DOMAIN,
                                        'SUFeedURL',
                                        BBEDIT_SUFEED_URL)

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
