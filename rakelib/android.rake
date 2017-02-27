# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'.freeze
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/2.2.3.0/android-studio-ide-145.3537739-mac.dmg'.freeze
ANDROID_SIGNATURE = { sha1: '51f282234c3a78b4afc084d8ef43660129332c37' }.freeze

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
