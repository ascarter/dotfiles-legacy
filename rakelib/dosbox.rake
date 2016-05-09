# DosBox tasks

namespace "dosbox" do
	desc "Install DosBox"
	task :install do
		if RUBY_PLATFORM =~ /darwin/
			pkg_url = 'http://downloads.sourceforge.net/project/dosbox/dosbox/0.74/DOSBox-0.74-1_Universal.dmg?r=http%3A%2F%2Fwww.dosbox.com%2Fdownload.php%3Fmain%3D1&ts=1462745380&use_mirror=iweb'
			unless app_exists("DosBox")
				pkg_download(pkg_url) do |p|
					dmg_mount(p) { |d| app_install(File.join(d, "DosBox.app")) }
				end
			end
		end
	end
		
	desc "Uninstall DosBox"
	task :uninstall do
		app_remove("DosBox")
	end
	
	namespace "boxer" do
		desc "Install boxer"
		task :install do
			pkg_url = 'http://boxerapp.com/download/latest'
			
			if RUBY_PLATFORM =~ /darwin/
				unless app_exists("Boxer")
					pkg_download(pkg_url) do |p|
						unzip(p)
	          app_install(File.join(File.dirname(p), "Boxer.app"))
	        end
				end
			else
				raise "Platform not supported"
			end
		end
		
		desc "Uninstall boxer"
		task :uninstall do
			app_remove("Boxer")
		end
	end
end
