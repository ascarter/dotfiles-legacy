# Android SDK

ANDROID_STUDIO_APP = 'Android Studio'.freeze
ANDROID_SOURCE_URL = 'https://dl.google.com/dl/android/studio/install/2.3.1.0/android-studio-ide-162.3871768-mac.dmg'.freeze
ANDROID_SIGNATURE = { sha2: 'f8a414f7f4111a9aba059c7b85a3f0aba6abc950552a270042daa488922db377' }.freeze

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
