# Yarn tasks

YARN_ROOT = '/opt/yarn'.freeze
YARN_PACKAGES = %w(eslint js-beautify)

namespace 'yarn' do
	desc 'Install yarn'
	task :install do
		if File.exist?(YARN_ROOT)
			warn 'yarn installed'
		else
			Bootstrap.sudo_mkdir(YARN_ROOT)
			Bootstrap.sudo_chown(YARN_ROOT)
			Bootstrap.sudo_chgrp(YARN_ROOT, 'admin')
			Bootstrap.sudo_chmod(YARN_ROOT)
			
			system %(curl -o- -L https://yarnpkg.com/latest.tar.gz | tar xz  --strip-components 1 -C #{YARN_ROOT})

			if Bootstrap.macosx?
				# Setup path helper
				Bootstrap::MacOSX.path_helper('yarn', [File.join(YARN_ROOT, 'bin')])
			else
				warn "Add the following to startup profile (.bashrc):\nexport PATH=${PATH}:#{YARN_ROOT}/bin"
			end
		end		
	end

	Rake::Task[:install].enhance do
		Rake::Task['yarn:packages:install'].invoke
	end

	desc 'Update yarn'
	task :update => [:uninstall, :install]

	desc 'Uninstall yarn'
	task uninstall: ['yarn:packages:uninstall'] do
		if Bootstrap.macosx?
      %w(paths manpaths).each { |t| Bootstrap::MacOSX.rm_path_helper('yarn', t) }
    end
    Bootstrap.sudo_rmdir YARN_ROOT
	end

	namespace 'packages' do
		desc 'Install default global yarn packages'
		task :install do
			YARN_PACKAGES.each { |pkg| Bootstrap::Yarn.install(pkg) }
		end
		
		desc 'Uninstall global yarn packages'
		task :uninstall do
			Bootstrap::Yarn.list.each do |pkg|
				pkg_name = pkg.split('@')[0]
				Bootstrap::Yarn.uninstall(pkg_name)
			end
		end
		
		desc 'List global yarn packages'
		task :list do
			Bootstrap::Yarn.ls
		end
	end
end
