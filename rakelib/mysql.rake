# MySQL

namespace "mysql" do
  if Bootstrap.macosx?
    SEQUELPRO_APP_NAME = 'Sequel Pro'
    SEQUELPRO_SOURCE_URL = 'https://github.com/sequelpro/sequelpro/releases/download/release-1.1.2/sequel-pro-1.1.2.dmg'

    namespace "sequelpro" do
      desc "Install Sequel Pro"
      task :install do
        Bootstrap::MacOSX::App.install(SEQUELPRO_APP_NAME, SEQUELPRO_SOURCE_URL)
      end
  
      desc "Uninstall Sequel Pro"
      task :uninstall do
        Bootstrap::MacOSX::App.uninstall(SEQUELPRO_APP_NAME)
      end
    end
  end
end


