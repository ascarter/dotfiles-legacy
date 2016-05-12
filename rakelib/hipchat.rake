# HipChat

namespace "hipchat" do	
	desc 'Install HipChat'
	task :install do
		case RUBY_PLATFORM
		when /darwin/
		  Bootstrap::MacOSX::App.install('HipChat', 'https://www.hipchat.com/downloads/latest/mac')
		end
	end
	
	desc 'Uninstall HipChat'
	task :uninstall do
		case RUBY_PLATFORM
		when /darwin/
		  Bootstrap::MacOSX::App.uinstall('HipChat')
		end
	end
end