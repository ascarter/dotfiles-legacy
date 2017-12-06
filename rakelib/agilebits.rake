# Agile Bits 1Password tasks

ONEPASSWORD_PKG_NAME = '1Password-6.8.2'.freeze
ONEPASSWORD_PKG_ID = 'com.agilebits.pkg.onepassword'.freeze
ONEPASSWORD_SOURCE_URL= 'https://app-updates.agilebits.com/download/OPM4'.freeze
ONEPASSWORD_SAFARI_EXTENSION = '1Password-4.6.11'.freeze
ONEPASSWORD_SAFARI_SOURCE_URL = 'https://cache.agilebits.com/dist/1P/ext/#{ONEPASSWORD_SAFARI_EXTENSION}.safariextz'.freeze
ONEPASSWORD_CMDLINE_SOURCE_URL = 'https://cache.agilebits.com/dist/1P/op/pkg/v0.1.1/op_darwin_amd64_v0.1.1.zip'.freeze
ONEPASSWORD_CMDLINE_APP = 'op'.freeze

namespace '1password' do
  desc 'About 1Password'
  task :about do
    Bootstrap.about('1Password', 'Password manager', 'https://1password.com')
  end

  desc 'Install 1Password'
  task :install => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(ONEPASSWORD_PKG_NAME, ONEPASSWORD_PKG_ID, ONEPASSWORD_SOURCE_URL)

      # Install command line tool
      unless Bootstrap.usr_bin_exists?('op')
        Bootstrap::Downloader.download_with_extract(ONEPASSWORD_CMDLINE_SOURCE_URL) do |d|
          `gpg --verify #{File.join(d, 'op.sig')} #{File.join(d, 'op')}`
          Bootstrap.usr_bin_cp(File.join(d, ONEPASSWORD_CMDLINE_APP), ONEPASSWORD_CMDLINE_APP)
        end
      end
    end
  end

  desc 'Uninstall 1Password'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap.usr_bin_rm(ONEPASSWORD_CMDLINE_APP)
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
