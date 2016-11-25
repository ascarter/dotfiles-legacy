# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'.freeze
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/2.2.2.0/android-studio-ide-145.3360264-mac.dmg'.freeze
ANDROID_SIGNATURE = { sha1: '2e89fed3601e5bd19112c29c172cb29be3b34f8e' }.freeze

namespace 'android' do
  desc 'Install Android SDK'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(ANDROID_STUDIO_APP,
                                     ANDROID_SOURCE_URL,
                                     sig: ANDROID_SIGNATURE)
    end
  end

  desc 'Uninstall Android SDK'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(ANDROID_STUDIO_APP)
    end
  end

  desc 'Update Android SDK'
  task update: [:uninstall, :install]
end
