# Firefox
# https://www.mozilla.org/en-US/firefox

FIREFOX_APP_NAME = 'Firefox'.freeze
FIREFOX_SOURCE_URL = 'https://download.mozilla.org/?product=firefox-50.1.0-SSL&os=osx&lang=en-US'.freeze

FIREFOX_DEV_APP_NAME = 'FirefoxDeveloperEdition'.freeze
FIREFOX_DEV_SOURCE_URL = 'https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=osx&lang=en-US'.freeze

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

  namespace 'developer' do
    desc 'Install Firefox developer edition'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(FIREFOX_DEV_APP_NAME, FIREFOX_DEV_SOURCE_URL)
      end
    end

    desc 'Uninstall Firefox developer edition'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(FIREFOX_DEV_APP_NAME)
      end
    end
  end

end
