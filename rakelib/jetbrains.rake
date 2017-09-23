# JetBrains toolbox

TOOLBOX_APP_NAME = 'JetBrains Toolbox'.freeze
TOOLBOX_SOURCE_URL = 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.4.2492.dmg'.freeze
TOOLBOX_SIGNATURE = { sha256: 'd8426a5dc0c9c46773a8a41b72e71b8f80cdac0545e942d4fff3f2dabcbf3a68' }.freeze

namespace 'jetbrains' do
  desc 'Install JetBrains Toolbox'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(TOOLBOX_APP_NAME, TOOLBOX_SOURCE_URL, sig: TOOLBOX_SIGNATURE)
    end
  end

  desc 'Uninstall JetBrains Toolbox'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(TOOLBOX_APP_NAME)
    end
  end
end
