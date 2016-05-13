# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.1.2.dmg'

namespace "intellij" do
  desc "Install IntelliJ IDEA"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(INTELLIJ_APP_NAME, INTELLIJ_SOURCE_URL)
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


