# surfeasy tasks

SURFEASY_APP_NAME = 'SurfEasy VPN'
SURFEASY_SOURCE_URL = 'https://accounts.surfeasy.com/downloads/surfeasyvpn/macinstaller'

namespace 'surfeasy' do
	desc 'Install surfeasy'
	task :install do
		Bootstrap::MacOSX::App.install(SURFEASY_APP_NAME, SURFEASY_SOURCE_URL)
	end
	
	desc 'Uninstall surfeasy'
	task :uninstall do
		Bootstrap::MacOSX::App.uninstall(SURFEASY_APP_NAME)
	end	
end
