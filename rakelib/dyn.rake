# Dyn DNS tasks

DYN_APP_NAME = 'Dyn Updater'.freeze
DYN_SOURCE_URL = 'http://cdn.dyn.com/dynupdater/DynUpdater.dmg'.freeze

namespace 'dyn' do
  desc 'Install dyn'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(DYN_APP_NAME, DYN_SOURCE_URL)
    end
  end

  desc 'Uninstall dyn'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(DYN_APP_NAME)
    end
  end
end
