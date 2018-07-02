# HandBrake tasks

HANDBRAKE_APP_NAME = 'Handbrake'.freeze
HANDBRAKE_SRC_URL = 'http://handbrake.fr/rotation.php?file=HandBrake-1.0.7.dmg'.freeze

HANDBRAKE_CLI_APP_NAME = 'HandbrakeCLI'.freeze
HANDBRAKE_CLI_SRC_URL = 'https://handbrake.fr/rotation.php?file=HandBrakeCLI-1.0.7.dmg'.freeze

namespace 'handbrake' do
  desc 'About HandBrake'
  task :about do
    Bootstrap.about('HandBrake', 'The open source video transcoder', 'https://handbrake.fr')
  end

  desc 'Install HandBrake'
  task :install  => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.install(HANDBRAKE_APP_NAME, HANDBRAKE_SRC_URL)

      # Install command line utility
      unless Bootstrap.usr_bin_exists?('HandbrakeCLI')
        Downloader.download_with_extract(HANDBRAKE_CLI_SRC_URL) do |d|
          Bootstrap.usr_bin_cp(File.join(d, HANDBRAKE_CLI_APP_NAME), HANDBRAKE_CLI_APP_NAME)
          Bootstrap.usr_bin_ln(Bootstrap.usr_bin_cmd(HANDBRAKE_CLI_APP_NAME), 'handbrake')
        end
      end

      # Install libdvdcss
      Homebrew.install('libdvdcss')
    end
  end

  desc 'Uninstall HandBrake'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Homebrew.uninstall('libdvdcss')
      MacOS::App.uninstall(HANDBRAKE_APP_NAME)
      Bootstrap.usr_bin_rm('handbrake')
      Bootstrap.usr_bin_rm(HANDBRAKE_CLI_APP_NAME)
    end
  end
end
