# GitHub tasks

namespace "github" do 
  desc "Install GitHub tools and apps"
  task :install => [ :tools, :desktop ]

  desc "Install GitHub tools"
  task :tools do
    puts "Installing GitHub tools"
    brew_install("gist")
    brew_install("hub")
  end

  desc "Install GitHub Desktop"
  task :desktop do
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
    
  desc "Uninstall GitHub tools"
  task :uninstall do
    puts "Uninstalling GitHub tools"
    brew_uninstall("gist")
    brew_uninstall("hub")
    
    if RUBY_PLATFORM =~ /darwin/
      app_remove("Github Desktop")
    end
  end
end
