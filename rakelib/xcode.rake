# Xcode tasks

namespace "xcode" do
  desc "Install Xcode command line tools"
  task :install do
    sudo "xcode-select --install"
  end

  desc "Uninstall Xcode command line tools"
  task :uninstall do
    # TODO: Uninstall Xcode command line tools
    puts 'Not yet implemented'
  end
end
