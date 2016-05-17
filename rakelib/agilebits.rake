# Agile Bits 1Password tasks

ONEPASSWORD_SAFARI_EXTENSION = '1Password-4.5.6'
ONEPASSWORD_SAFARI_SOURCE_URL = 'https://cache.agilebits.com/dist/1P/ext/1Password-4.5.6.safariextz'

namespace '1password' do
  if Bootstrap.macosx?
    namespace 'safari' do
      desc 'Install 1Password Safari Extension'
      task :install do
        Bootstrap::MacOSX::SafariExtension.install(ONEPASSWORD_SAFARI_EXTENSION, ONEPASSWORD_SAFARI_SOURCE_URL)
      end
    end
  end
end
