# MySQL

MYSQL_PKG_NAME = 'mysql-5.7.19-macos10.12-x86_64'.freeze
MYSQL_PKG_IDS= %w(com.mysql.mysql com.mysql.launchd com.mysql.prefpane).freeze
MYSQL_SOURCE_URL = "https://dev.mysql.com/get/Downloads/MySQL-5.7/#{MYSQL_PKG_NAME}.dmg".freeze
MYSQL_SIGNATURE = { md5: '999a9461663f3f873afe0c165316ef86' }.freeze
MYSQL_ROOT = '/usr/local/mysql'.freeze

namespace 'mysql' do
  desc 'Install MySQL server'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOS::Pkg.install(MYSQL_PKG_NAME, MYSQL_PKG_IDS[0], MYSQL_SOURCE_URL, sig: MYSQL_SIGNATURE)
      Bootstrap::MacOS.path_helper('mysql', [File.join(MYSQL_ROOT, 'bin')])
      Bootstrap::MacOS.path_helper('mysql', [File.join(MYSQL_ROOT, 'man')], 'manpaths')
    end
  end

  desc 'Uninstall MySQL server'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MYSQL_PKG_IDS.each { |p| Bootstrap::MacOS::Pkg.uninstall(p) }
      %w(paths manpaths).each { |t| Bootstrap::MacOS.rm_path_helper('mysql', t) }
    end
  end

  if Bootstrap.macOS?
    SEQUELPRO_APP_NAME = 'Sequel Pro'.freeze
    SEQUELPRO_SOURCE_URL = 'https://github.com/sequelpro/sequelpro/releases/download/release-1.1.2/sequel-pro-1.1.2.dmg'.freeze

    namespace 'sequelpro' do
      desc 'Install Sequel Pro'
      task :install do
        Bootstrap::MacOS::App.install(SEQUELPRO_APP_NAME, SEQUELPRO_SOURCE_URL)
      end

      desc 'Uninstall Sequel Pro'
      task :uninstall do
        Bootstrap::MacOS::App.uninstall(SEQUELPRO_APP_NAME)
      end
    end
  end
end
