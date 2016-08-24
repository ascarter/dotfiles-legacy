# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'.freeze
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.2.2.dmg'.freeze
INTELLIJ_SIGNATURE = { sha2: '47641ade715a1fed88ab8d3656f9505e420d180a5df79cf469b21217ba6c99f6' }.freeze

namespace 'intellij' do
  desc 'Install IntelliJ IDEA'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(INTELLIJ_APP_NAME, INTELLIJ_SOURCE_URL, sig: INTELLIJ_SIGNATURE)
    end
  end

  desc 'Uninstall IntelliJ IDEA'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(INTELLIJ_APP_NAME)
    end
  end

  desc 'Update IntelliJ IDEA'
  task update: [:uninstall, :install]
end
