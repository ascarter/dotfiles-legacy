# Go language tasks

GOLANG_PKG_NAME = 'go1.7rc1.darwin-amd64'
GOLANG_PKG_ID = 'com.googlecode.go'
GOLANG_SOURCE_URL= 'https://storage.googleapis.com/golang/go1.7rc1.darwin-amd64.pkg'

namespace "golang" do
  desc "Install Go language"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(GOLANG_PKG_NAME, GOLANG_PKG_ID, GOLANG_SOURCE_URL)
    end
          
    # Add go tool to the working path
    ENV['PATH'] += ":/usr/local/go/bin"

    puts %x{go version}

    # Install/update gows
    gows_root = File.expand_path(File.join(Bootstrap.home_dir(), '.gows'))
    unless File.exist?(gows_root)
      puts "Installing gows..."
      Bootstrap::Git.clone('ascarter/gows', gows_root)
    else
      puts "Updating gows..."
      Bootstrap::Git.pull(gows_root)
    end
  end

  desc "Info on Go language"
  task :info do
    go = File.join('/usr/local/go', 'bin', 'go')
    if File.exist?(go)
      puts %x{#{go} version}      
      puts Bootstrap::MacOSX::Pkg.info(GOLANG_PKG_ID) if RUBY_PLATFORM =~ /darwin/
    else
      warn 'Go language is not installed'
    end
  end

  desc "Uninstall Go language"
  task :uninstall do
    puts "Uninstalling go language..."
    go_root = File.expand_path('/usr/local/go')
    if File.exist?(go_root)
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::Pkg.uninstall(GOLANG_PKG_ID)
        Bootstrap.sudo_rmdir(go_root)
      end
    else
      warn 'Go language is not installed'
    end
  end

  desc 'Update Go language'
  task update: [:uninstall, :install]
end
