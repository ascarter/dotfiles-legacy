# audiohijack tasks

AUDIOHIJACK_APP_NAME = 'Audio Hijack'.freeze
AUDIOHIJACK_SOURCE_URL = 'http://rogueamoeba.com/audiohijack/download/AudioHijack.zip'.freeze

namespace 'audiohijack' do
  desc 'Install audiohijack'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(AUDIOHIJACK_APP_NAME, AUDIOHIJACK_SOURCE_URL)
    end
  end
  
  desc 'Uninstall audiohijack'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(AUDIOHIJACK_APP_NAME)
    end
  end 
end
