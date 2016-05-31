# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.1.2b.dmg'
INTELLIJ_SIGNATURE = {sha2: '21d2a850ac5da0dfa0197cee85b31d797136629d82cc84d914ca91d503c1d0a1'}

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


