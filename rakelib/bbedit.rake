# BBEdit tasks

namespace "bbedit" do
  desc "Install bbedit"
  task :install do
    barebones_root = "https://s3.amazonaws.com/BBSW-download"
    barebones_pine_root = "http://pine.barebones.com/files"
    domain = "com.barebones.bbedit"
    
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("BBEdit")
        # Install BBEdit
        release = '11.5.1'
        pkg = "BBEdit_#{release}"
        pkg_url = "#{barebones_root}/#{pkg}.dmg"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d| app_install(File.join(d, "BBEdit.app")) }
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
        zipfile = "BBEdit11.5AutomatorActionsInstaller.zip"
        pkg = "BBEditAutomatorActionsInstaller-11.5.pkg"
        pkg_download("#{barebones_pine_root}/#{zipfile}") do |p|
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
      if app_exists("BBEdit")
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
        app_remove("BBEdit")
      end
    end
  end
end
