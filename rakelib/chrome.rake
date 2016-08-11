# Chrome tasks

CHROME_APP_NAME = 'Google Chrome'.freeze
CHROME_SOURCE_URL = 'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg'.freeze

namespace 'chrome' do
  desc 'Install Google Chrome'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(CHROME_APP_NAME, CHROME_SOURCE_URL)
    end
  end

  desc 'Uninstall Google Chrome'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(CHROME_APP_NAME)
    end
  end
end
