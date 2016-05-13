# Atom tasks

ATOM_APP_NAME = 'Atom'
ATOM_SRC_URL = 'https://atom.io/download/mac'
ATOM_PKGS = %w{dash}

namespace "atom" do
  desc "Install atom"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ATOM_APP_NAME, ATOM_SRC_URL)      
      
      # Install command line tools
      puts "To install command line tools, select Atom -> Install Shell Commands"
    when /linux/
      puts "NYI: Install atom.x86_64 package"
    when /windows/
      puts "NYI: Install via AtomSetup.exe"
    else
      raise "Platform not supported"
    end
    
    ATOM_PKGS.each { |p| Bootstrap::APM.install(p) }
  end

  desc "Uninstall atom"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # apm modules
      if File.exist?('/usr/local/bin/apm')
        Bootstrap::APM.list().each { |p| Bootstrap::APM.uninstall(p) }
      end
    
      # Command line tools
      %w{atom apm}.each { |c| usr_bin_rm(c) }
    
      # Application
      Bootstrap::App.uninstall("Atom")
    end    
  end
end
