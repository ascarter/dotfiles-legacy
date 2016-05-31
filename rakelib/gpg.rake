# gpg tasks

GPG_PKG_NAME = 'Install'
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
  'org.gpgtools.pinentry-mac.pkg',
]
GPG_UNINSTALL_APP_NAME = 'Uninstall'
GPG_SOURCE_URL = 'https://releases.gpgtools.org/GPG_Suite-2015.09.dmg'
GPG_SIGNATURE = {sha1: 'f1fd930144720e70bd4c809dd36ac0573b0a7be2'}

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
end
