# GitHub tasks

namespace "github" do 
  desc "Install GitHub tools"
  task :install do
    puts "Installing GitHub tools"
    brew_install("gist")
  end
  
  desc "Uninstall GitHub tools"
  task :uninstall do
    puts "Uninstalling GitHub tools"
    brew_uninstall("gist")
  end
end
