# steam tasks

STEAM_APP_NAME = 'Steam'
STEAM_SOURCE_URL = 'https://steamcdn-a.akamaihd.net/client/installer/steam.dmg'

STEAM_TIME_MACHINE_INFO = <<EOF

Exclude Steam from Time Machine
===============================

When setting up Time Machine on your computer make sure that you exclude the
/Users/[username]/Library/Application Support/Steam/SteamApps/:

* Open Time Machine
* Click on the lock in the bottom left to edit your preferences
* Click on Options
* Click on the little '+' sign at the bottom to exclude a specific directory
* Add your /Users/[username]/Library/Application Support/Steam/SteamApps/ folder
  to the exception list

Time Machine will no longer backup your SteamApps folder each time a game is updated.
This will avoid large amounts of data being backed up with only minor updates.
EOF

namespace 'steam' do
	desc 'Install steam'
	task :install do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::App.install(STEAM_APP_NAME, STEAM_SOURCE_URL, owner: Bootstrap.current_user)
  		
  		# Warn to exclude SteamApps from TimeMachine
  		puts STEAM_TIME_MACHINE_INFO
  	end
	end
	
	desc 'Uninstall steam'
	task :uninstall do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::App.uninstall(STEAM_APP_NAME)
  		Bootstrap.file_remove(File.join(Bootstrap.home_dir, 'Library', 'Application Support', 'Steam'))
  	end
	end	
end
