# Android SDK

namespace "android" do
  desc "Install Android SDK"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("Android Studio")
        pkg_root = 'https://dl.google.com/dl/android/studio/install'
        pkg_ver = '2.0.0.20'
        pkg_file = 'android-studio-ide-143.2739321-mac.dmg'
        pkg_url = "#{pkg_root}/#{pkg_ver}/#{pkg_file}"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d| app_install(File.join(d, "Android Studio.app")) }
        end
      end
    end
  end
  
  desc "Uninstall Android SDK"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      app_remove("Android Studio")
    end
  end
end


