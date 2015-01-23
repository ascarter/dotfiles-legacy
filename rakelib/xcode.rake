# Xcode tasks

namespace "xcode" do
  desc "Install Xcode command line tools"
  task :install do
    sudo "xcode-select --install"
  end
  
  desc "Install Xcode themes"
  task :themes do
    src = File.join(File.dirname(__FILE__), "../xcode/themes")
    dest = File.expand_path("~/Library/Developer/Xcode/UserData/FontAndColorThemes/")
    FileUtils.mkdir_p(dest)
    FileUtils.cp(Dir.glob(File.join(src, "*.dvtcolortheme")), dest)
  end

  desc "Uninstall Xcode command line tools"
  task :uninstall do
    # TODO: Uninstall Xcode command line tools
    puts 'Not yet implemented'
  end
end
