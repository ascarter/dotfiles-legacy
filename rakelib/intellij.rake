# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'.freeze
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.2.dmg'.freeze
INTELLIJ_SIGNATURE = { sha2: '0e156bc6e0ee021527f2a5e3d123cc55f0d24dfe7d0dfb96f58dd0e18f0b6161' }.freeze

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
