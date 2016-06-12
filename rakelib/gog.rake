# gog tasks

GOG_APP_NAME = 'GalaxyClient'
GOG_PKG_NAME = 'galaxy_client_1.1.11.56'
GOG_PKG_ID = 'com.gog'
GOG_SOURCE_URL = 'http://cdn.gog.com/open/galaxy/client/galaxy_client_1.1.11.56.pkg'

namespace 'gog' do
  desc 'Install gog'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(GOG_PKG_NAME, GOG_PKG_ID, GOG_SOURCE_URL)
    end
  end

  desc 'Uninstall gog'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(GOG_APP_NAME)
    end
  end	
end
