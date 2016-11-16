# geekbench tasks

GEEKBENCH_APP_NAME = 'Geekbench 4'.freeze
GEEKBENCH_SOURCE_URL = 'http://cdn.primatelabs.com/Geekbench-4.0.3-Mac.dmg'.freeze

namespace 'geekbench' do
  desc 'Install geekbench'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(GEEKBENCH_APP_NAME, GEEKBENCH_SOURCE_URL)
    end
  end
  
  desc 'Uninstall geekbench'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(GEEKBENCH_APP_NAME)
    end
  end 
end
