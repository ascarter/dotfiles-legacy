# paw tasks

PAW_APP_NAME = 'Paw'.freeze
PAW_SOURCE_URL = 'https://paw.cloud/download'.freeze

namespace 'paw' do
  desc 'Install Paw'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(PAW_APP_NAME, PAW_SOURCE_URL)
    end
  end

  desc 'Uninstall Paw'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(PAW_APP_NAME)
    end
  end
end
