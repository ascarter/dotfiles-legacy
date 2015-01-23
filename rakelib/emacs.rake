# Emacs tasks

namespace "emacs" do
  desc "Install Emacs"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install Emacs for Mac OS X
      unless File.exist?('/Applications/Emacs.app')
        version = '24.4'
        pkg = "Emacs-#{version}-universal.dmg"
        pkg_url = "http://emacsformacosx.com/emacs-builds/#{pkg}"
        pkg_download(pkg_url) do |p|
          src = dmg_mount(p)
          app_install(File.join(src, "Emacs.app"))
          dmg_unmount(src)
        end
      else
        puts "Emacs already installed"
      end

      # Symlink emacs
      memacs = File.join(File.dirname(__FILE__), "../src/bin/memacs")
      usr_bin_ln(memacs, "emacs")
      
      # Symlink emacsclient
      emacasclient = "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
      usr_bin_ln(emacasclient, "emacsclient")
    end
    
    puts %x{emacs --version}
  end

  desc "Uninstall Emacs"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      # Remove symlinks
      %w{emacs emacasclient}.each { |c| usr_bin_rm(c) }
      
      # Remove application
      app_remove("Emacs")
    end
  end
end
