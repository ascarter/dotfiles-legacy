# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/2.1.1.0/android-studio-ide-143.2821654-mac.dmg'

namespace "android" do
  desc "Install Android SDK"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ANDROID_STUDIO_APP, ANDROID_SOURCE_URL)
    end
  end
  
  desc "Uninstall Android SDK"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ANDROID_STUDIO_APP)
    end
  end
end


