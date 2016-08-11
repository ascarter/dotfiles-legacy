# vlc tasks

VLC_APP_NAME = 'VLC'.freeze
VLC_SOURCE_URL = 'https://get.videolan.org/vlc/2.2.4/macosx/vlc-2.2.4.dmg'.freeze

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
