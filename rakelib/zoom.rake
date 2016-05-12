# Zoom

namespace "zoom" do
  ZOOM_PKG_ID = 'us.zoom'
  ZOOM_APP = 'zoom.us'
  
	desc 'Install Zoom'
	task :install do
		case RUBY_PLATFORM
		when /darwin/
		  unless Bootstrap::MacOSX::App.exists?(ZOOM_APP)
		    Bootstrap::MacOSX::Pkg.install('zoomusinstaller', ZOOM_PKG_ID, 'https://www.zoom.us/client/latest/zoomusInstaller.pkg')
		  else
		    warn 'Zoom already installed'
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