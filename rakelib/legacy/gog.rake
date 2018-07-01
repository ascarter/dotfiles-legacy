# gog tasks

GOG_APP_NAME = 'GalaxyClient'.freeze
GOG_PKG_NAME = 'galaxy_client_1.1.11.56'.freeze
GOG_PKG_ID = 'com.gog'.freeze
GOG_SOURCE_URL = 'http://cdn.gog.com/open/galaxy/client/galaxy_client_1.1.11.56.pkg'.freeze

namespace 'gog' do
  desc 'Install gog'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::Pkg.install(GOG_PKG_NAME, GOG_PKG_ID, GOG_SOURCE_URL)
    end
  end

  desc 'Uninstall gog'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.uninstall(GOG_APP_NAME)
    end
  end
end
