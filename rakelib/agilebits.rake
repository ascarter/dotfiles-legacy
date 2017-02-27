# Agile Bits 1Password tasks

ONEPASSWORD_APP_NAME = '1Password 6'.freeze
ONEPASSWORD_SOURCE_URL= 'https://app-updates.agilebits.com/download/OPM4'.freeze
ONEPASSWORD_SAFARI_EXTENSION = '1Password-4.6.3'.freeze
ONEPASSWORD_SAFARI_SOURCE_URL = 'https://cache.agilebits.com/dist/1P/ext/1Password-4.6.3.safariextz'.freeze

namespace '1password' do
  desc 'Install 1Password'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ONEPASSWORD_APP_NAME, ONEPASSWORD_SOURCE_URL)
    end
  end

  desc 'Uninstall 1Password'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ONEPASSWORD_APP_NAME)
    end
  end

  if Bootstrap.macosx?
    namespace 'safari' do
      desc 'Install 1Password Safari Extension'
      task :install do
        Bootstrap::MacOSX::SafariExtension.install(ONEPASSWORD_SAFARI_EXTENSION,
                                                   ONEPASSWORD_SAFARI_SOURCE_URL)
      end
    end
  end
end
