# IntelliJ IDEA

INTELLIJ_APP_NAME = 'IntelliJ IDEA CE'.freeze
INTELLIJ_SOURCE_URL = 'https://download.jetbrains.com/idea/ideaIC-2016.2.5.dmg'.freeze
INTELLIJ_SIGNATURE = { sha256: '6fce76f374f7b5a19e50a2aade2ea854151326c563fbaed77da3b40b702ac70b' }.freeze

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
