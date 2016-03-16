# Atom tasks


pkgs = %w{dash auto-detect-indentation}

namespace "atom" do
  desc "Install atom"
  task :install do

    unless File.exist?('/usr/local/bin/atom')  
      case RUBY_PLATFORM
      when /darwin/
        app = "Atom.app"
        pkg_url = "https://atom.io/download/mac"
        pkg_download(pkg_url) do |p|
          unzip(p)
          app_install(File.join(File.dirname(p), app))
        end
        
        # Install command line tools
        puts "To install command line tools, select Atom -> Install Shell Commands"
      when /linux/
        puts "NYI: Install atom.x86_64 package"
      when /windows/
        puts "NYI: Install via AtomSetup.exe"
      else
        raise "Platform not supported"
      end
    end
  end

  desc "Uninstall atom"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # apm modules
      if File.exist?('/usr/local/bin/apm')
        apm_list().each { |p| apm_uninstall(p) }
      end
    
      # Command line tools
      %w{atom apm}.each { |c| usr_bin_rm(c) }
    
      # Application
      app_remove("Atom")
    end    
  end
end
