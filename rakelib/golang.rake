# Go language tasks

namespace "golang" do
  desc "Install Go language"
  task :install do
    go_root = File.expand_path('/usr/local/go')
    go_prog = File.join(go_root, 'bin', 'go')

    unless File.exist?(go_root)
      # Download and install go package
      if RUBY_PLATFORM =~ /darwin/
        release = '1.3.3'
        pkg = "go#{release}.darwin-amd64-osx10.8.pkg"
        pkg_url = "https://storage.googleapis.com/golang/#{pkg}"
        pkg_download(pkg_url) do |p|
          pkg_install(p)
        end
      end
    end
    
    puts %x{#{go_prog} version}

    # Install/update goenv
    goenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.goenv')))
    unless File.exist?(goenv_root.to_s)
      puts "Installing goenv..."
      git_clone('ascarter', 'goenv', goenv_root)
    else
      puts "Updating goenv..."
      git_pull(goenv_root)
    end
  end

  desc "Uninstall Go language"
  task :uninstall do
    puts "Uninstalling goenv..."
    goenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.goenv')))
    file_remove(goenv_root)
    
    puts "Uninstalling go language..."
    go_root = File.expand_path('/usr/local/go')
    if File.exist?(go_root)
      if RUBY_PLATFORM =~ /darwin/
        pkg_uninstall("com.googlecode.go")
        sudo_remove_dir(go_root)
      end
    end
  end
end
