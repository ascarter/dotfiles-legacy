# Node.js tasks

namespace "node" do
  desc "Install node.js"
  task :install, [:version] do |t, args|
    args.with_defaults(:version => 'v4.1.1')
    if RUBY_PLATFORM =~ /darwin/
      # Install node.js from package
      unless File.exist?('/usr/local/bin/node')
        # TODO: Get list of releases and prompt user to pick
        release = args.version
        pkg = "node-#{release}.pkg"
        pkg_url = "http://nodejs.org/dist/#{release}/#{pkg}"
        pkg_download(pkg_url) do |p|
          pkg_install(p)
        end
      end
    end

    node_version

    # Install npm packages
    pkgs = %w{grunt-cli bower}
    pkgs.each { |pkg| npm_install(pkg) }
  end

  desc "List installed modules"
  task :list do
    node_version
    npm_ls
  end

  desc "Uninstall node.js"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if File.exist?('/usr/local/bin/node')
        if File.exist?('/usr/local/bin/npm')
          # Remove all installed node modules and npm
          npm_list.each do |pkg|
            npm_uninstall pkg
          end

          npm_uninstall "npm"
        end

        pkgs = %w{org.nodejs.node.npm.pkg org.nodejs.pkg}
        pkgs.each { |pkg| pkg_uninstall(pkg) }

        dirs = [
          "/usr/local/lib/node",
          "/usr/local/lib/node_modules",
          "/usr/local/include/node"
        ]
        dirs.each { |dir| sudo_remove_dir(dir) }
      else
        puts 'Node.js is not installed'
      end
    end
  end

  desc "Update node.js"
  task update: [:uninstall, :install]
end
