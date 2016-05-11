# HipChat tasks

namespace "hipchat" do	
  app = MacOSX::App.new("HipChat", 'https://www.hipchat.com/downloads/latest/mac')
  
	desc "Install HipChat"
	task :install do
		if RUBY_PLATFORM =~ /darwin/
		  app.install
		end
	end
	
	task :uninstall do
	  if RUBY_PLATFORM =~ /darwin/
	    app.uninstall
	  end
	end
end