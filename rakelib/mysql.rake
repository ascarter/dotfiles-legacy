# MySQL

namespace "mysql" do
  namespace "sequelpro" do
    desc "Install Sequel Pro"
    task :install do
      if RUBY_PLATFORM =~ /darwin/
        unless app_exists("Sequel Pro")
          pkg_ver = '1.1.2'
          pkg_url = "https://github.com/sequelpro/sequelpro/releases/download/release-#{pkg_ver}/sequel-pro-#{pkg_ver}.dmg"
          pkg_download(pkg_url) do |p|
            src = dmg_mount(p)
            app_install(File.join(src, "Sequel Pro.app"))
            dmg_unmount(src)
          end
        end
      end
    end
  
    desc "Uninstall Sequel Pro"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        app_remove("Sequel Pro")
      end
    end
  end
end


