# JetBrains toolbox

TOOLBOX_APP_NAME = 'JetBrains Toolbox'.freeze
TOOLBOX_SOURCE_URL = 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.6.2914.dmg'.freeze
TOOLBOX_SIGNATURE = { sha256: '566a7043491635228ae31b58dabbb085ae77671cfb4317afd0e0f48dc4706079' }.freeze

namespace 'jetbrains' do
  desc 'Install JetBrains Toolbox'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOS::App.install(TOOLBOX_APP_NAME, TOOLBOX_SOURCE_URL, sig: TOOLBOX_SIGNATURE)
    end
  end

  desc 'Uninstall JetBrains Toolbox'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOS::App.uninstall(TOOLBOX_APP_NAME)
    end
  end
end
