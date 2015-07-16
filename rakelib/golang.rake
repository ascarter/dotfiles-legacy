# Go language tasks

namespace "golang" do
  desc "Install Go language"
  task :install do
    root = File.expand_path('/usr/local/go')
    prog = File.join(root, 'bin', 'go')

    unless File.exist?(root)
      # Download and install go package
      if RUBY_PLATFORM =~ /darwin/
        release = '1.4.2'
        pkg = "go#{release}.darwin-amd64-osx10.8.pkg"
        pkg_url = "https://storage.googleapis.com/golang/#{pkg}"
        pkg_download(pkg_url) do |p|
          pkg_install(p)
        end
      end
    end

    puts %x{#{prog} version}

    # Init default workspace
    workspace = File.join(ENV['HOME'], '.go')
    unless File.exist?(workspace)
      puts "Initialize default go workspace at #{workspace}"
      mkdir workspace
    end

    # Install default packages
    pkgs = %w[
      github.com/ChimeraCoder/gojson/...
      github.com/derekparker/delve/cmd/dlv
      github.com/golang/lint/golint
      github.com/jstemmer/gotags
      github.com/mailgun/godebug
      golang.org/x/tools/cmd/goimports
      golang.org/x/tools/cmd/present
      golang.org/x/tools/oracle
    ]
    pkgs.each { |p| go_get(workspace, p) }

    # Install/update gows
    gows_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.gows')))
    unless File.exist?(gows_root.to_s)
      puts "Installing gows..."
      git_clone('ascarter/gows', gows_root)
    else
      puts "Updating gows..."
      git_pull(gows_root)
    end
  end

  desc "Info on Go language"
  task :info do
    root = File.expand_path('/usr/local/go')
    prog = File.join(root, 'bin', 'go')
    if File.exist?(prog)
      puts %x{#{prog} version}
      if RUBY_PLATFORM =~ /darwin/
        pkg_id = "com.googlecode.go"
        puts pkg_info(pkg_id)
      end
    else
      puts "Go language is not installed"
    end
  end

  desc "Uninstall Go language"
  task :uninstall do
    puts "Uninstalling go language..."
    root = File.expand_path('/usr/local/go')
    if File.exist?(root)
      if RUBY_PLATFORM =~ /darwin/
        pkg_id = "com.googlecode.go"
        pkg_uninstall(pkg_id)
        sudo_remove_dir(root)
      end
    else
      puts "Go language is not installed"
    end
  end

  desc "Update Go language"
  task update: [:uninstall, :install]
end
