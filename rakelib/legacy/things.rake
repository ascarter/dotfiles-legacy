# Things tasks

if Bootstrap.macosx?
	THINGS_APP_NAME = 'Things'.freeze
	THINGS_SOURCE_URL = 'https://culturedcode.com/things/download/'.freeze
	THINGS_HELPER_APP_NAME = 'Things Helper'.freeze
	THINGS_HELPER_SOURCE_URL = 'http://culturedcode.cachefly.net/things/thingssandboxhelper/3.4/ThingsHelper.zip'.freeze

	namespace 'things' do
		desc 'Install Things'
		task :install do
			Bootstrap::MacOSX::App.install(THINGS_APP_NAME, THINGS_SOURCE_URL)
			Bootstrap::MacOSX::App.launch(THINGS_APP_NAME)
		end

		desc 'Uninstall Things'
		task :uninstall do
			Bootstrap::MacOSX::App.uninstall(THINGS_APP_NAME)
		end

		namespace 'helper' do
      desc 'Install Things Helper'
		  task :install do
        Bootstrap::MacOSX::App.run(THINGS_HELPER_APP_NAME, THINGS_HELPER_SOURCE_URL)
		  end

  		desc 'Uninstall Things Helper'
		  task :uninstall do
		    helper_path = File.join(Bootstrap.home_dir, 'Library', 'Application Support', 'Things Sandbox Helper')
        if File.exist?(helper_path)
          puts "Uninstalling Things Helper"
          Bootstrap.sudo_rmdir helper_path
        else
          warn "Things Helper is not installed"
        end
		  end
		end
	end
end
