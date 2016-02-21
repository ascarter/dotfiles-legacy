
# BBEdit tasks
# defaults write com.barebones.bbedit CloseOFBNWindowAfterOpeningSelection -bool YES

namespace "bbedit" do
  desc "Install bbedit"
  task :install do
    barebones_root = "http://pine.barebones.com/files"
    domain = "com.barebones.bbedit"
    
    if RUBY_PLATFORM =~ /darwin/
      unless File.exist?("/Applications/BBEdit.app")
        # Install BBEdit
        release = '11.0.2'
        pkg = "BBEdit_#{release}"
        pkg_url = "#{barebones_root}/#{pkg}.dmg"
        pkg_download(pkg_url) do |p|
          src = dmg_mount(p)
          app_install(File.join(src, "BBEdit.app"))
          dmg_unmount(src)
        end
      end

      # TODO: Set license key

      # Install command line utils
      unless File.exist?('/usr/local/bin/bbedit')
        run_applescript('/Applications/BBEdit.app/Contents/Resources/BBEdit Help/install_tools.scpt')
        app_hide("BBEdit")
      end
      
      # Install automator actions
      unless File.exist?('/Library/Automator/AddLineNumbers.action')
        zipfile = "BBEdit11AutomatorActionsInstaller.zip"
        pkg = "BBEditAutomatorActionsInstaller-11.0_3470.pkg"
        pkg_download("#{barebones_root}/#{zipfile}") do |p|
          unzip(p)
          pkg_install(File.join(File.dirname(p), pkg))
        end
      end
      
      # Set preferences
      defaults_write(domain, "CloseOFBNWindowAfterOpeningSelection", "YES", "-bool")
      defaults_write(domain, "SUFeedURL", "http://pine.barebones.com/rowboat/BBEdit.xml")

      puts %x{bbedit --version}
    end
  end

  desc "Uninstall bbedit"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      bbedit_path = '/Applications/BBEdit.app'
      if File.exist?(bbedit_path)
        # Command line tools
        usr_bin = '/usr/local/bin'
        %w{bbdiff bbedit bbfind}.each do |p|
          target = File.expand_path(File.join(usr_bin, p))
          sudo_remove(target)
        end
        
        # Man pages
        usr_man = '/usr/local/share/man/man1'
        %w{bbdiff.1 bbedit.1 bbfind.1}.each do |m|
          target = File.expand_path(File.join(usr_man, m))
          sudo_remove(target)
        end
        
        # Automator actions
        if File.exist?('/Library/Automator/AddLineNumbers.action')
          pkg_uninstall('com.barebones.bbedit.automatorActions')
        end
              
        # Remove application
        sudo_remove_dir(bbedit_path)
      end
    end
  end
end
