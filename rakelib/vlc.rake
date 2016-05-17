# vlc tasks

VLC_APP_NAME = 'VLC'
VLC_SOURCE_URL = 'http://get.videolan.org/vlc/2.2.3/macosx/vlc-2.2.3.dmg'

namespace 'vlc' do
  desc 'Install VLC'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(VLC_APP_NAME, VLC_SOURCE_URL)
    end
  end
  
  desc 'Uninstall VLC'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(VLC_APP_NAME)
    end
  end
end