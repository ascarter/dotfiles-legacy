FORK_APP_NAME = 'Fork'.freeze
FORK_SOURCE_URL = 'https://git-fork.com/update/files/Fork.dmg'.freeze

namespace 'fork' do
  desc 'About fork'
  task :about do
    Bootstrap.about('Fork', 'A fast and friendly git client for Mac', 'https://git-fork.com')
  end

  desc 'Install Fork'
  task :install => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(FORK_APP_NAME, FORK_SOURCE_URL)
    end
  end

  desc 'Uninstall Fork'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(FORK_APP_NAME)
    end
  end
end
