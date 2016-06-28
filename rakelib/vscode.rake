# Microsoft Visual Studio Code

VSCODE_APP_NAME = 'Visual Studio Code'
VSCODE_SOURCE_URL = 'https://go.microsoft.com/fwlink/?LinkID=620882'

namespace 'vscode' do
	desc 'Install vscode'
	task :install do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::App.install(VSCODE_APP_NAME, VSCODE_SOURCE_URL)
      
      # Install command line tools
      Bootstrap.usr_bin_ln('/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code', 'vscode')
	  end
	end
	
	desc 'Uninstall vscode'
	task :uninstall do
	  case RUBY_PLATFORM
	  when /darwin/
	    Bootstrap.usr_bin_rm('vscode')
  		Bootstrap::MacOSX::App.uninstall(VSCODE_APP_NAME)
  	end
	end	
end
