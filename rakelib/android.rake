# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'.freeze
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/3.0.1.0/android-studio-ide-171.4443003-mac.dmg'.freeze
ANDROID_SIGNATURE = { sha256: 'c4e0e3da447f4517128ee1a767ed130721fd2c0e0a1b311ce7dbc05766dcd221' }.freeze

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
