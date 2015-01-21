
# BBEdit tasks
# defaults write com.barebones.bbedit CloseOFBNWindowAfterOpeningSelection -bool YES

namespace "bbedit" do
  desc "Install bbedit"
  task :install do
    domain = "com.barebones.bbedit"
    
    if RUBY_PLATFORM =~ /darwin/
      unless File.exist?("/Applications/BBEdit.app")
        # Download BBEdit
        release = '11.0.2'
        pkg = "BBEdit_#{release}"
        pkg_url = "http://pine.barebones.com/files/#{pkg}.dmg"
        pkg_download(pkg_url) do |p|
          src = dmg_mount(p)
          install_app("#{src}/BBEdit.app")
          dmg_unmount(src)
        end
        # TODO: Set license key
        
        # Install command line utils
        run_applescript('/Applications/BBEdit.app/Contents/Resources/BBEdit Help/install_tools.scpt')
        hide_app("BBEdit")
      end
      
      # Set preferences
      defaults_write(domain, "CloseOFBNWindowAfterOpeningSelection", "YES", "-bool")

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
        
        # Application
        sudo_remove_dir(bbedit_path)
      end
    end
  end
end
