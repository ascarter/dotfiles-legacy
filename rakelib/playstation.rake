# Sony PlayStation tasks

PS4_PKG_NAME = 'RemotePlayInstaller'.freeze
PS4_PKG_ID = 'com.playstation.RemotePlay.pkg'.freeze
PS4_SOURCE_URL = 'https://remoteplay.dl.playstation.net/remoteplay/module/mac/RemotePlayInstaller.pkg'.freeze

namespace 'ps4' do
  desc 'Install Sony PlayStation 4 Remote Play'
  task :install do
    Bootstrap::MacOSX::Pkg.install(PS4_PKG_NAME, PS4_PKG_ID, PS4_SOURCE_URL)
  end

  desc 'Uninstall Sony PlayStation 4 Remote Play'
  task :uninstall do
    Bootstrap::MacOSX::Pkg.uninstall(PS4_PKG_ID)
  end
end
