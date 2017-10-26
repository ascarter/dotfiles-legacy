# Go language tasks

GOLANG_PKG_ID = 'com.googlecode.go'.freeze
GOLANG_PKG_NAME = 'go1.9.2.darwin-amd64'.freeze
GOLANG_SOURCE_URL = "https://storage.googleapis.com/golang/#{GOLANG_PKG_NAME}.pkg".freeze

GOTOOLS = [
  'github.com/davecheney/httpstat'.freeze,
  'github.com/golang/dep/cmd/dep'.freeze,
  'github.com/golang/lint/golint'.freeze,
  'golang.org/x/tools/cmd/goimports'.freeze,
  'golang.org/x/tools/cmd/gorename'.freeze,
  'golang.org/x/tools/cmd/guru'.freeze,
  'golang.org/x/tools/cmd/html2article'.freeze,
  'golang.org/x/tools/cmd/present'.freeze
]

DELVE_PKG = 'github.com/derekparker/delve/cmd/dlv'

namespace 'golang' do
  desc 'Install Go language'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(GOLANG_PKG_NAME,
                                     GOLANG_PKG_ID,
                                     GOLANG_SOURCE_URL)
    end

	# Add go tool to the working path
    ENV['PATH'] += ':/usr/local/go/bin'

    puts `go version`
  end

  Rake::Task[:install].enhance do
    Rake::Task['golang:workspace:install'].invoke
    Rake::Task['golang:debugger:install'].invoke
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
      ENV['GOPATH'] = Bootstrap.workspace_dir
      %w(bin pkg src).each do |d|
        p = File.join(Bootstrap.workspace_dir, d)
        unless File.exist?(p)
          puts "Initializing #{p}"
          FileUtils.mkdir_p(p)
        end

        # Add extra directories
        case d
        when "src"
          # Create scratch directories
          %w(go javascript ruby).each do |s|
            FileUtils.mkdir_p(File.join(p, 'scratch', s))
          end
        end
      end
    end

    task :readme do
      readme_path = File.join(Bootstrap.workspace_dir, 'README.md')
      unless File.exists?(readme_path)
        # Write projects README
        File.open(readme_path, 'w') do |f|
          f.write <<-EOF
# Development Projects Workspace

This is a workspace for software development projects. It uses the prescribed layout
for [Go](https://golang.org/doc/code.html#Workspaces). This layout is compatible with
other languages as well.

The following are the directories and their usage:

	* `src` contains source code for projects
	* `pkg` contains package objects (Go specific)
	* `bin` contains executable commands and should be added to `PATH` environment variable

EOF
        end
      end
    end

    Rake::Task[:init].enhance do
      Rake::Task['golang:workspace:readme'].invoke
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

  namespace 'debugger' do
    desc 'Install delve debugger'
    task :install => ['golang:workspace:init'] do
      delve_dir = File.join(Bootstrap.workspace_dir, 'src', 'github.com', 'derekparker', 'delve')
      Bootstrap::Go.get(DELVE_PKG, noinstall: true)
      Bootstrap::Go.sudo("make -C #{delve_dir} install")
      system "dlv version"
    end

    desc 'Uninstall delve debugger'
    task :uninstall do
      Bootstrap::Go.clean(DELVE_PKG)
    end
  end
end
