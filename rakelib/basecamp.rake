# Basecamp tasks

BASECAMP_APP_NAME = 'Basecamp 3'.freeze
BASECAMP_SOURCE_URL = 'https://bc3-desktop.s3.amazonaws.com/mac/basecamp3.dmg'.freeze

namespace 'basecamp' do
  desc 'Install basecamp'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(BASECAMP_APP_NAME, BASECAMP_SOURCE_URL)
    end
  end

  desc 'Uninstall basecamp'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(BASECAMP_APP_NAME)
    end
  end
end
