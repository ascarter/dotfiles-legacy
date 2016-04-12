# IntelliJ IDEA

namespace "intellij" do
  desc "Install IntelliJ IDEA"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("IntelliJ IDEA CE")
        pkg_ver = '2016.1.1'
        pkg_url = "https://download.jetbrains.com/idea/ideaIC-#{pkg_ver}.dmg"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d| app_install(File.join(d, "IntelliJ IDEA CE.app")) }
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


