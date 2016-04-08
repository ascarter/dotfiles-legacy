# IntelliJ IDEA

namespace "intellij" do
  desc "Install IntelliJ IDEA"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("IntelliJ IDEA CE")
        pkg_ver = '2016.1.1'
        pkg_url = "https://download.jetbrains.com/idea/ideaIC-#{pkg_ver}.dmg"
        pkg_download(pkg_url) do |p|
          src = dmg_mount(p)
          app_install(File.join(src, "IntelliJ IDEA CE.app"))
          dmg_unmount(src)
        end
      end
    end
  end
  
  desc "Uninstall IntelliJ IDEA"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      app_remove("IntelliJ IDEA CE")
    end
  end
end


