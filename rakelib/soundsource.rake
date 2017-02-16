# Rogue Amoeba SoundSource tasks

SOUNDSOURCE_APP_NAME = 'SoundSource'.freeze
SOUNDSOURCE_SOURCE_URL = 'https://rogueamoeba.com/soundsource/download/SoundSource.zip'.freeze

namespace 'soundsource' do
  desc 'Install SoundSource'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SOUNDSOURCE_APP_NAME, SOUNDSOURCE_SOURCE_URL)
    end
  end
  
  desc 'Uninstall SoundSource'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SOUNDSOURCE_APP_NAME)
    end
  end 
end
