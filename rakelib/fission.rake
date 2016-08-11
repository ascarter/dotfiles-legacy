# Fission tasks

FISSION_APP_NAME = 'Fission'.freeze
FISSION_SOURCE_URL = 'http://rogueamoeba.com/fission/download/Fission.zip'.freeze

namespace 'fission' do
  desc 'Install fission'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(FISSION_APP_NAME, FISSION_SOURCE_URL)
    end
  end

  desc 'Uninstall fission'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(FISSION_APP_NAME)
    end
  end
end
