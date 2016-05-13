# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'

namespace "android" do
  desc "Install Android SDK"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ANDROID_STUDIO_APP, 'https://dl.google.com/dl/android/studio/install/2.1.1.0/android-studio-ide-143.2821654-mac.dmg')
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


