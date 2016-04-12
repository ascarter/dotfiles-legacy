# HandBrake tasks

namespace "handbrake" do
  desc "Install HandBrake"
  task :install do
    handbrake_http_root = "https://handbrake.fr/rotation.php"
    release = '0.10.2'
    
    if RUBY_PLATFORM =~ /darwin/
      unless File.exist?("/Applications/HandBrake.app")
        # Install Handbrake app
        pkg = "HandBrake-#{release}-MacOSX.6_GUI_x86_64"
        pkg_url = "#{handbrake_http_root}?file=#{pkg}.dmg"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d| app_install(File.join(src, "HandBrake.app")) }
        end
      end

      # Install command line utility
      handbrake_cli = '/usr/local/bin/HandBrakeCLI'
      unless File.exist?(handbrake_cli)
        pkg = "HandBrake-#{release}-MacOSX.6_CLI_x86_64"
        pkg_url = "#{handbrake_http_root}?file=#{pkg}.dmg"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d|  sudo "cp #{File.join(d, "HandBrakeCLI")} /usr/local/bin/." }
        end
        
        # Symlink handbrake
        usr_bin_ln(handbrake_cli, 'handbrake') if File.exist?(handbrake_cli)
      end
    end
  end

  desc "Uninstall HandBrake"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      handbrake_app = '/Applications/HandBrake.app'
      handbrake_cli = '/usr/local/bin/HandbrakeCLI'
      handbrake_alias = '/usr/local/bin/handbrake'

      sudo_remove_dir(handbrake_app) if File.exist?(handbrake_app)
      sudo_remove(handbrake_cli) if File.exist?(handbrake_cli)
      sudo_remove(handbrake_alias)
    end
  end
end
