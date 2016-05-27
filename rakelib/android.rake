# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/2.1.1.0/android-studio-ide-143.2821654-mac.dmg'
ANDROID_SHA1 = '4a7ca7532a95c65ee59ed50193c0e976f0272472'

namespace "android" do
  desc "Install Android SDK"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ANDROID_STUDIO_APP, ANDROID_SOURCE_URL, sig: ANDROID_SHA1)
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


