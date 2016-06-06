# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.1.3.dmg'
INTELLIJ_SIGNATURE = {sha2: 'b33cf612e40598347f05115da6168c003edb57e792f1abe52cd919bfb39961c1'}

namespace "intellij" do
  desc "Install IntelliJ IDEA"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(INTELLIJ_APP_NAME, INTELLIJ_SOURCE_URL, sig: INTELLIJ_SIGNATURE)
    end
  end
  
  desc "Uninstall IntelliJ IDEA"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(INTELLIJ_APP_NAME)
    end
  end
end


