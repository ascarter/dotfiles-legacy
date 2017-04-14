# Sublime Text tasks
SUBL_APP_NAME = 'Sublime Text'.freeze
SUBL_SOURCE_URL = 'https://download.sublimetext.com/Sublime%20Text%20Build%203126.dmg'.freeze

namespace 'sublime' do
  desc 'Install sublime'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SUBL_APP_NAME, SUBL_SOURCE_URL)
    
      # TODO: set license key
    
      if RUBY_PLATFORM =~ /darwin/
        subl_root = File.expand_path("/Applications/#{SUBL_APP_NAME}.app/Contents/SharedSupport")
      end
    
      if File.exist?(subl_root)
        # Symlink sublime programs
        subl_path = File.join(subl_root, 'bin', 'subl')
        Bootstrap.usr_bin_ln(subl_path, 'subl')
      end
    end
  end

  desc 'Uninstall sublime'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # Remove symlinks
      Bootstrap.usr_bin_rm('subl')
      
      Bootstrap::MacOSX::App.uninstall(SUBL_APP_NAME)
    end
  end
end
