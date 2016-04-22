# Docker tasks

namespace "docker" do
  desc "Install Docker"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      unless pkg_exists("com.docker.something")
        choices = File.join(File.dirname(__FILE__), "docker_choices.xml")
        pkg_ver = '1.11.0'
        pkg_url = "https://github.com/docker/toolbox/releases/download/v1.11.0/DockerToolbox-1.11.0.pkg"
        pkg_download(pkg_url) { |p| pkg_install(p, choices) }
      end
    end
  end
  
  desc "Uninstall Docker"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      pkgs = %w{
        io.boot2dockeriso.pkg.boot2dockeriso
        io.docker.pkg.docker
        io.docker.pkg.dockercompose
        io.docker.pkg.dockermachine
        io.docker.pkg.dockerquickstartterminalapp
        io.docker.pkg.kitematicapp
      }      
      pkgs.each { |p| pkg_uninstall(p) }
      sudo_remove_dir  File.join('/Applications', 'Docker')
    end
  end
end