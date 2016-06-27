# Node.js tasks

NODEJS_PKG_IDS = %w{org.nodejs.node.pkg}
NODEJS_PKG_NAME = 'node-v4.4.6'
NODEJS_SOURCE_URL = 'https://nodejs.org/dist/v4.4.6/node-v4.4.6.pkg'

NPM_PKGS = %w{grunt-cli bower}

namespace 'node' do
  desc 'Install node.js'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(NODEJS_PKG_NAME, NODEJS_PKG_IDS[0], NODEJS_SOURCE_URL)
    end

    Bootstrap::NodeJS.version

    # Install npm packages
    NPM_PKGS.each { |pkg| Bootstrap::NPM.install(pkg) }
  end

  desc 'List installed modules'
  task :list do
    Bootstrap::NodeJS.version
    Bootstrap::NPM.ls
  end

  desc 'Uninstall node.js'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      if File.exist?('/usr/local/bin/node') && File.exist?('/usr/local/bin/npm')
        Bootstrap::NPM.list.each { |p| Bootstrap::NPM.uninstall(p) }
        Bootstrap::NPM.uninstall('npm')
        
        NODEJS_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
        
        dirs = [
          '/usr/local/lib/node',
          '/usr/local/lib/node_modules',
          '/usr/local/include/node'
        ]
        dirs.each { |dir| Bootstrap.sudo_rmdir(dir) }
      else
        warn 'Node.js and npm are not installed'
      end
    end
  end

  desc 'Update node.js'
  task update: [:uninstall, :install]
end
