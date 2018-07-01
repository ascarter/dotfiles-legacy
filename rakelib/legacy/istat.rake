# iStat tasks

ISTAT_SERVER_APP_NAME = 'iStat Server'.freeze
ISTAT_SERVER_SOURCE_URL = 'https://download.bjango.com/istatserver'.freeze
ISTAT_MENUS_APP_NAME = 'iStat Menus'.freeze
ISTAT_MENUS_SOURCE_URL = 'http://download.bjango.com/istatmenus/'.freeze

namespace 'istat' do
  namespace 'server' do
    desc 'Install iStat Server'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(ISTAT_SERVER_APP_NAME, ISTAT_SERVER_SOURCE_URL)
      end
    end
  
    desc 'Uninstall iStat Server'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(ISTAT_SERVER_APP_NAME)
      end
    end 
  end
  
  namespace 'menus' do
    desc 'Install iStat Menus'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(ISTAT_MENUS_APP_NAME, ISTAT_MENUS_SOURCE_URL)
      end
    end

    desc 'Uninstall iStat Menus'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(ISTAT_MENUS_APP_NAME)
      end
    end    
  end  
end
