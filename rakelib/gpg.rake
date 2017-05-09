# gpg tasks

GPG_PKG_NAME = 'Install'.freeze
GPG_PKG_IDS = [
  'org.gpgtools.macgpg2.pkg',
  'org.gpgtools.checkprivatekey.pkg',
  'org.gpgtools.gpgkeychain.pkg',
  'org.gpgtools.gpgmail_11.pkg',
  'org.gpgtools.gpgpreferences.pkg',
  'org.gpgtools.gpgservices.pkg',
  'org.gpgtools.key',
  'org.gpgtools.libmacgpg.xpc.pkg',
  'org.gpgtools.libmacgpgB.pkg',
  'org.gpgtools.pinentry-mac.pkg'
].freeze
GPG_UNINSTALL_APP_NAME = 'Uninstall'.freeze
GPG_SOURCE_URL = 'https://releases.gpgtools.org/GPG_Suite-2017.1b3-v2.dmg'.freeze
GPG_SIGNATURE = { sha256: ' a29edb4f44abfb1608a6a957aca21e6cc21d1b2c5f400ea5008f2ac18cb8cbc1' }.freeze
GPG_DEFAULTS_DOMAIN = 'org.gpgtools.gpgmail'.freeze

namespace 'gpg' do
  desc 'Install gpg'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(GPG_PKG_NAME, GPG_PKG_IDS[0], GPG_SOURCE_URL, sig: GPG_SIGNATURE)
    end
  end

  desc 'Uninstall gpg'
  task :uninstall do
    Bootstrap::MacOSX::App.run(GPG_UNINSTALL_APP_NAME, GPG_SOURCE_URL, sig: GPG_SIGNATURE)
  end

  namespace 'sign' do
    desc 'Set default signing method to GPG'
    task :gpg do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::Defaults.write(GPG_DEFAULTS_DOMAIN, 'DefaultSecurityMethod', 1, '-int')
        puts Bootstrap::MacOSX::Defaults.read(GPG_DEFAULTS_DOMAIN)
      end
    end

    desc 'Set default signing method to S/MIME'
    task :smime do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::Defaults.write(GPG_DEFAULTS_DOMAIN, 'DefaultSecurityMethod', 2, '-int')
        puts Bootstrap::MacOSX::Defaults.read(GPG_DEFAULTS_DOMAIN)
      end
    end
  end
end
