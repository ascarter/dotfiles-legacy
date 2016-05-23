# MySQL


MYSQL_PKG_NAME='mysql-5.7.12-osx10.11-x86_64'
MYSQL_PKG_ID='org.mysql'
MYSQL_SRC_URL='http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.12-osx10.11-x86_64.dmg'

namespace "mysql" do
  desc 'Install MySQL server'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(MYSQL_PKG_NAME, MYSQL_PKG_ID, MYSQL_PKG_URL)
    end
  end
  
  desc 'Uninstall MySQL server'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.uninstall(MYSQL_PKG_ID)
    end
  end

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


