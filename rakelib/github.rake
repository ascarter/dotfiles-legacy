# GitHub tasks

namespace "github" do 
  desc "Install GitHub tools and apps"
  task :install => [ 'tools:install', 'desktop:install', 'tower:install', 'gitx:install' ]
  task :uninstall => [ 'tools:uninstall', 'dekstop:uninstall', 'tower:uninstall', 'gitx:uninstall' ]

  namespace "tools" do
    desc "Install GitHub tools"
    task :install do
      brew_install("gist")
      brew_install("hub")
    end
    
    desc "Uninstall GitHub tools"
    task :uninstall_tools do
      brew_uninstall("gist")
      brew_uninstall("hub")
    end
  end

  namespace "desktop" do
    desc "Install GitHub Desktop"
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        unless app_exists("Github Desktop")
          pkg_url = 'https://central.github.com/mac/latest'
          pkg_download(pkg_url) do |p|
            unzip(p)
            app_install(File.join(File.dirname(p), "Github Desktop.app"))
          end
        end
      when /linux/
        puts "NYI"
      when /windows/
        puts "NYI"
      else
        raise "Platform not supported"
      end
    end

    desc "Uninstall GitHub Desktop"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        app_remove("Github Desktop")
      end
    end
  end
  
  namespace "tower" do
    desc "Install Tower"
    task :install do
      if RUBY_PLATFORM =~ /darwin/
        unless app_exists("Tower")
          pkg_url = 'https://updates.fournova.com/tower2-mac/stable/releases/latest/download'
          pkg_download(pkg_url) do |p|
              unzip(p)
              app_install(File.join(File.dirname(p), "Tower.app"))
          end
        end
      else
        raise "Platform not supported"
      end
    end

    desc "Uninstall Tower"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        app_remove("Tower")
      end
    end
  end
  
  namespace "gitx" do
    desc "Install GitX"
    task :install do
      if RUBY_PLATFORM =~ /darwin/
        unless app_exists("GitX")
          pkg_url = 'http://builds.phere.net/GitX/development/GitX-dev.dmg'
          pkg_download(pkg_url) do |p|
            dmg_mount(p) { |d| app_install(File.join(d, "GitX.app")) }
          end
        end
      else
        raise "Platform not supported"
      end
    end
    
    desc "Uninstall GitX"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        app_remove("GitX")
      end
    end
  end
  
  namespace "gitup" do
    desc "Install GitUp"
    task :install do
      if RUBY_PLATFORM =~ /darwin/
        unless app_exists("GitUp")
          pkg_url = 'https://s3-us-west-2.amazonaws.com/gitup-builds/stable/GitUp.zip'
          pkg_download(pkg_url) do |p|
            unzip(p)
            app_install(File.join(File.dirname(p), "GitUp.app"))
          end
        end
      end
    end
    
    desc "Uninstall GitUp"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        usr_bin_rm("gitup")
        app_remove("GitUp")
      end
    end
  end
end
