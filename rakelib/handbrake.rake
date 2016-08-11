# HandBrake tasks

HANDBRAKE_APP_NAME = 'Handbrake'
HANDBRAKE_SRC_URL = 'http://handbrake.fr/rotation.php?file=HandBrake-0.10.5-MacOSX.6_GUI_x86_64.dmg'

HANDBRAKE_CLI_APP_NAME = 'HandbrakeCLI'
HANDBRAKE_CLI_SRC_URL = 'https://handbrake.fr/rotation.php?file=HandBrake-0.10.5-MacOSX.6_CLI_x86_64.dmg'

namespace 'handbrake' do
  desc 'Install HandBrake'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(HANDBRAKE_APP_NAME, HANDBRAKE_SRC_URL)
      
      # Install command line utility
      unless Bootstrap.usr_bin_exists?('HandbrakeCLI')
        Bootstrap::Downloader.download_with_extract(HANDBRAKE_CLI_SRC_URL) do |d|
          Bootstrap.usr_bin_cp(File.join(d, HANDBRAKE_CLI_APP_NAME), HANDBRAKE_CLI_APP_NAME)
          Bootstrap.usr_bin_ln(File.join('/usr/local/bin', HANDBRAKE_CLI_APP_NAME), 'handbrake')
        end
      end
      
      # Install libdvdcss
      Bootstrap::Homebrew.install('libdvdcss')
    end
  end  

  desc 'Uninstall HandBrake'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::Homebrew.uninstall('libdvdcss')
      Bootstrap::MacOSX::App.remove(HANDBRAKE_APP_NAME)
      Bootstrap.usr_bin_rm('handbrake')
      Bootstrap.usr_bin_rm(HANDBRAKE_CLI_APP_NAME)
    end
  end
end
