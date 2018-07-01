# Apple San Francisco Font tasks

SFPRO_PKG_NAME = 'SFPro/San Francisco Pro'.freeze
SFPRO_PKG_ID = 'com.apple.pkg.San Francisco Pro'.freeze
SFPRO_SOURCE_URL = 'https://developer.apple.com/fonts/downloads/SFPro.zip'.freeze
SFCOMPACT_PKG_NAME = 'SFCompact/San Francisco Compact'.freeze
SFCOMPACT_PKG_ID = 'com.apple.pkg.San Francisco Compact'.freeze
SFCOMPACT_SOURCE_URL = 'https://developer.apple.com/fonts/downloads/SFCompact.zip'.freeze
SFMONO_SOURCE_PATH = '/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono*.otf'.freeze

namespace 'sanfrancisco' do
  desc 'Install San Francisco Fonts'
  task install: ['pro:install', 'compact:install', 'mono:install']

  desc 'Uninstall San Francisco Fonts'
  task uninstall: ['mono:uninstall', 'pro:uninstall', 'compact:uninstall']

  namespace 'pro' do
    desc 'Install San Francisco Pro Fonts'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::Pkg.install(SFPRO_PKG_NAME, SFPRO_PKG_ID, SFPRO_SOURCE_URL)
      end
    end
  
    desc 'Uninstall San Francisco Pro Fonts'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::Pkg.uninstall(SFPRO_PKG_ID)
      end
    end 
  end

  namespace 'compact' do
    desc 'Install San Francisco Compact Fonts'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::Pkg.install(SFCOMPACT_PKG_NAME, SFCOMPACT_PKG_ID, SFCOMPACT_SOURCE_URL)
      end
    end
  
    desc 'Uninstall San Francisco Compact Fonts'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::Pkg.uninstall(SFCOMPACT_PKG_ID)
      end
    end 
  end

  namespace 'mono' do
    desc 'Install San Francisco Mono (requires Xcode 8 or later)'
    task :install do
      Dir.glob(SFMONO_SOURCE_PATH).each do |f|
        FileUtils.cp(f, File.join(FONT_DIR, File.basename(f)))
      end
    end

    desc 'Uninstall San Francisco Mono'
    task :uninstall do
      MacOS::Font.uninstall('SFMono')
    end
  end
end