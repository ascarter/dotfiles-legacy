# vmware tasks

VMWARE_APP_NAME = 'VMWare Fusion'.freeze
VMWARE_SOURCE_URL = 'https://www.vmware.com/go/try-fusionpro-en'.freeze
VMWARE_SIGNATURE = {
  md5: '4584b6405b612da75792b1519da3c205',
  sha1: '9e584951f39583f1a9d74cd64ecef26dd37217a2',
  sha256: '29cad381a36374e58a85fb58f7aaad8cae41ad50ef07fdda0db6d782c95c0a95'
}.freeze
VMWARE_APP_FILES = [
  '/Library/Application Support/VMware',
  '/Library/Application Support/VMware Fusion',
  '/Library/Preferences/VMware Fusion',
  '~/Library/Application Support/VMware Fusion',
  '~/Library/Caches/com.vmware.fusion',
  '~/Library/Preferences/VMware Fusion',
  '~/Library/Preferences/com.vmware.fusion.LSSharedFileList.plist',
  '~/Library/Preferences/com.vmware.fusion.LSSharedFileList.plist.lockfile',
  '~/Library/Preferences/com.vmware.fusion.plist',
  '~/Library/Preferences/com.vmware.fusion.plist.lockfile',
  '~/Library/Preferences/com.vmware.fusionDaemon.plist',
  '~/Library/Preferences/com.vmware.fusionDaemon.plist.lockfile',
  '~/Library/Preferences/com.vmware.fusionStartMenu.plist',
  '~/Library/Preferences/com.vmware.fusionStartMenu.plist.lockfile'
].freeze

namespace 'vmware' do
  desc 'Install vmware'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.run(VMWARE_APP_NAME, VMWARE_SOURCE_URL, sig: VMWARE_SIGNATURE)
    end
  end

  desc 'Uninstall vmware'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.uninstall(VMWARE_APP_NAME)
      VMWARE_APP_FILES.each { |f| Bootstrap.file_remove(File.expand_path(f)) }
    end
  end
end
