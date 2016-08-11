# Zoom

namespace 'zoom' do
  ZOOM_PKG_ID = 'us.zoom'.freeze
  ZOOM_APP = 'zoom.us'.freeze

  desc 'Install Zoom'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      if Bootstrap::MacOSX::App.exists?(ZOOM_APP)
        warn 'Zoom already installed'
      else
        Bootstrap::MacOSX::Pkg.install('zoomusinstaller', ZOOM_PKG_ID, 'https://www.zoom.us/client/latest/zoomusInstaller.pkg')
      end
    end
  end

  desc 'Uninstall Zoom'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ZOOM_APP)
    end
  end
end
