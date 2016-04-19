# Visaul Studio Code

namespace "vscode" do
  desc "Install Visual Studio Code"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      unless app_exists("Visual Studio Code")
        pkg_url = "https://go.microsoft.com/fwlink/?LinkID=620882"
        pkg_download(pkg_url) do |p|
          unzip(p)
          app_install(File.join(File.dirname(p), "Visual Studio Code.app"))
        end
      end
      
      # Install command line tools
      usr_bin_ln('/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code', 'vscode')
    when /linux/
      puts "NYI"
    when /windows/
      puts "NYI"
    else
      raise "Platform not supported"
    end
  end

  desc "Uninstall Visual Studio Code"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      usr_bin_rm('vscode')
      app_remove("Visual Studio Code")
    end    
  end
end
