# Android SDK

ANDROID_STUDIO_APP = "Android Studio"
ANDROID_SOURCE_URL = "https://dl.google.com/dl/android/studio/install/2.1.2.0/android-studio-ide-143.2915827-mac.dmg"
ANDROID_SIGNATURE = {sha1: "689889cd434cb883b3fbdc61faa288de98754116"}

namespace "android" do
  desc "Install Android SDK"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ANDROID_STUDIO_APP, ANDROID_SOURCE_URL, sig: ANDROID_SIGNATURE)
    end
  end
  
  desc "Uninstall Android SDK"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ANDROID_STUDIO_APP)
    end
  end
  
  desc "Update Android SDK"
  task :update => [ :uninstall, :install ]
end


