# Agile Bits 1Password tasks

ONEPASSWORD_PKG_NAME = '1Password-6.6.4'.freeze
ONEPASSWORD_PKG_ID = 'com.agilebits.onepassword4'
ONEPASSWORD_SOURCE_URL= 'https://app-updates.agilebits.com/download/OPM4'.freeze
ONEPASSWORD_SAFARI_EXTENSION = '1Password-4.6.3'.freeze
ONEPASSWORD_SAFARI_SOURCE_URL = 'https://cache.agilebits.com/dist/1P/ext/1Password-4.6.3.safariextz'.freeze

namespace '1password' do
  desc 'Install 1Password'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(ONEPASSWORD_PKG_NAME, ONEPASSWORD_PKG_ID, ONEPASSWORD_SOURCE_URL)
    end
  end

  desc 'Uninstall 1Password'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.uninstall(ONEPASSWORD_PKG_ID)
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
