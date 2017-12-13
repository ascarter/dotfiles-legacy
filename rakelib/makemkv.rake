MAKEMKV_APP_NAME = 'MakeMKV'.freeze
MAKEMKV_SOURCE_URL = 'http://www.makemkv.com/download/MAKEMKV_v1.10.8_osx.dmg'.freeze

namespace 'makemkv' do
  desc 'About MakeMKV'
  task :about do
    Bootstrap.about('MakeMKV', 'MakeMKV is a format converter (transcoder)', 'http://www.makemkv.com')
  end

  desc 'Install MakeMKV'
  task :install => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(MAKEMKV_APP_NAME, MAKEMKV_SOURCE_URL)
    end
  end

  desc 'Uninstall MakeMKV'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(MAKEMKV_APP_NAME)
    end
  end
end
