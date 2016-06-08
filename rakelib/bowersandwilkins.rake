# Bowers & Wilkins tasks

BW_APP_NAME = 'Bowers & Wilkins Control'
BW_SOURCE_URL = 'http://www.bwfirmware.com/software/airplay_setup/mac/latest'

namespace 'bw' do
	desc 'Install bw'
	task :install do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::App.install(BW_APP_NAME, BW_SOURCE_URL)
	  end
	end
	
	desc 'Uninstall bw'
	task :uninstall do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::App.uninstall(BW_APP_NAME)
	  end
	end	
end
