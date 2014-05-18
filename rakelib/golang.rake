# Go language tasks

namespace "golang" do
  desc "Install Go language"
  task :install do
    go_root = File.expand_path('/usr/local/go')
    go_user_dir = File.expand_path('~/.go')
    go_prog = File.join(go_root, 'bin', 'go')

    unless File.exist?(go_root)
      # Download and install go package
      if RUBY_PLATFORM =~ /darwin/
        release = '1.2.2'
        pkg = "go#{release}.darwin-amd64-osx10.8.pkg"
        pkg_url = "https://storage.googleapis.com/golang/#{pkg}"
        pkg_download(pkg_url) do |p|
          pkg_install(p)
        end
      end
    end

    # Configure default GOPATH repository
    unless File.exist?(go_user_dir)
      mkdir(go_user_dir)
    end

    puts %x{#{go_prog} version}

    # TODO: Install some standard go packages?
  end

  desc "Uninstall Go language"
  task :uninstall do
    go_root = File.expand_path('/usr/local/go')
    if File.exist?(go_root)
      if RUBY_PLATFORM =~ /darwin/
        pkg_uninstall("com.googlecode.go")
        sudo_remove_dir(go_root)
      end
    end
  end
end
