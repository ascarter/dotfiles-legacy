# firefox tasks

FIREFOX_APP_NAME = 'Firefox'.freeze
FIREFOX_SOURCE_URL = 'https://download.mozilla.org/?product=firefox-49.0.1-SSL&os=osx&lang=en-US'.freeze

namespace 'firefox' do
  desc 'Install firefox'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(FIREFOX_APP_NAME, FIREFOX_SOURCE_URL)
    end
  end

  desc 'Uninstall firefox'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(FIREFOX_APP_NAME)
    end
  end
end
