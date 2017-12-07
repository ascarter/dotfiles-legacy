KALEIDOSCOPE_APP_NAME = 'Kaleidoscope'.freeze
KALEIDOSCOPE_SOURCE_URL = 'https://cdn.kaleidoscopeapp.com/releases/Kaleidoscope-2.2.2-1376.zip'.freeze

namespace 'kaleidoscope' do
  desc 'About Kaleidoscope'
  task :about do
    Bootstrap.about('Kaleidoscope', 'Kaleidoscope is the world’s most powerful file comparison app.', 'https://www.kaleidoscopeapp.com')
  end

  desc 'Install kaleidoscope'
  task :install => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(KALEIDOSCOPE_APP_NAME, KALEIDOSCOPE_SOURCE_URL)
    end
  end

  desc 'Uninstall kaleidoscope'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(KALEIDOSCOPE_APP_NAME)
    end
  end
end
