# Go language tasks

namespace "golang" do
  desc "Install Go language"
  task :install do
    go_root = File.expand_path('/usr/local/go')
    go_prog = File.join(go_root, 'bin', 'go')

    unless File.exist?(go_root)
      # Download and install go package
      if RUBY_PLATFORM =~ /darwin/
        release = '1.4'
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
    
    # Install default packages
    go_workspace = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.go')))
    unless File.exist?(go_workspace.to_s)
      Dir.mkdir(go_workspace)
    end
    
    packages = [
      'github.com/tools/godep',
      'github.com/golang/lint/golint',
      'golang.org/x/tools/cmd/goimports',
      'golang.org/x/tools/oracle'
    ]
    packages.each { |pkg| go_get pkg }
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
  
  desc "Update Go language"
  task update: [:uninstall, :install]
end
