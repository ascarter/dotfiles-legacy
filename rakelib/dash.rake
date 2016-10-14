# dash tasks

DASH_APP_NAME = 'Dash'.freeze
DASH_SOURCE_URL = 'https://sanfrancisco.kapeli.com/downloads/v3/Dash.zip'.freeze

namespace 'dash' do
  desc 'Install dash'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(DASH_APP_NAME, DASH_SOURCE_URL)
    end
  end

  desc 'Uninstall dash'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(DASH_APP_NAME)
    end
  end
end
