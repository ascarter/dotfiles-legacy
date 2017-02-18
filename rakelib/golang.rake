# Go language tasks

GOLANG_PKG_ID = 'com.googlecode.go'.freeze
GOLANG_PKG_NAME = 'go1.8.darwin-amd64'.freeze
GOLANG_SOURCE_URL = "https://storage.googleapis.com/golang/#{GOLANG_PKG_NAME}.pkg".freeze
GOTOOLS = [
  'github.com/golang/dep/...'.freeze,
  'github.com/golang/lint/golint'.freeze,
  'golang.org/x/tools/cmd/callgraph'.freeze,
  'golang.org/x/tools/cmd/goimports'.freeze,
  'golang.org/x/tools/cmd/gorename'.freeze,
  'golang.org/x/tools/cmd/gotype'.freeze,
  'golang.org/x/tools/cmd/guru'.freeze,
  'golang.org/x/tools/cmd/html2article'.freeze,
  'golang.org/x/tools/cmd/present'.freeze
]

namespace 'golang' do
  desc 'Install Go language'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(GOLANG_PKG_NAME,
                                     GOLANG_PKG_ID,
                                     GOLANG_SOURCE_URL)
    end
    puts `go version`
  end

  Rake::Task[:install].enhance do
    Rake::Task['golang:workspace:install'].invoke
  end

  desc 'Info on Go language'
  task :info do
    go = File.join('/usr/local/go', 'bin', 'go')
    if File.exist?(go)
      puts `#{go} version`
      if RUBY_PLATFORM =~ /darwin/
        puts Bootstrap::MacOSX::Pkg.info(GOLANG_PKG_ID)
      end
    else
      warn 'Go language is not installed'
    end
  end

  desc 'Uninstall Go language'
  task :uninstall do
    puts 'Uninstalling go language...'
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

  namespace 'workspace' do
    desc 'Init Go workspace'
    task :init do
      gopath = ENV['GOPATH']
      unless gopath.nil?
        %w(bin pkg src).each do |d|
          p = File.join(gopath, d)
          unless File.exist?(p)
            puts "Initializing #{p}"
            FileUtils.mkdir_p(p)
          end
        end
      end
    end

    desc 'Clean Go workspace'
    task :clean do
      gopath = ENV['GOPATH']
      unless gopath.nil?
        puts "Cleaning Go workspace #{gopath}"
        %w(bin pkg).each { |d| FileUtils.rm_rf(Dir.glob(File.join(gopath, d, '*'))) }
      end
    end

    desc 'Install Go tools'
    task :install => ['golang:workspace:init'] do
      GOTOOLS.each { |t| Bootstrap::Go.get(t) }
    end

    desc 'Uninstall Go tools'
    task :uninstall do
      GOTOOLS.each { |t| Bootstrap::Go.clean(t) }
    end
  end
end
