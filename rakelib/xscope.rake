# xScope tasks

XSCOPE_APP_NAME = 'xScope'.freeze
XSCOPE_SOURCE_URL = 'http://iconfactory.com/assets/software/xscope/xScope-4.2.zip'.freeze

namespace 'xscope' do
  desc 'Install xScope'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(XSCOPE_APP_NAME, XSCOPE_SOURCE_URL)
    end
  end

  desc 'Uninstall xScope'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(XSCOPE_APP_NAME)
    end
  end
end
