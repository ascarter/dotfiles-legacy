# JetBrains toolbox

TOOLBOX_APP_NAME = 'JetBrains Toolbox'.freeze
TOOLBOX_SOURCE_URL = 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.1.2143.dmg'.freeze
TOOLBOX_SIGNATURE = { sha256: '2498a80625b858742a534d0e6b6ba2cea458bb1e7efe967f0e1b3721e11d5957' }.freeze

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
