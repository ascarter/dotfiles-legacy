# Node.js tasks

namespace "node" do
  desc "Install node"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install node.js from package
      unless File.exist?('/usr/local/bin/node')
        # TODO: Get list of releases and prompt user to pick
        release = 'v0.10.29'
        pkg = "node-#{release}.pkg"
        pkg_url = "http://nodejs.org/dist/#{release}/#{pkg}"
        pkg_download(pkg_url) do |p|
          pkg_install(p)
        end
      end
    end
    
    node_version
    
    # Install npm packages
    pkgs = %w{bower grunt-cli jslint jsonlint}
    pkgs.each { |pkg| npm_install(pkg) }
  end
  
  desc "List installed modules"
  task :list do
    node_version
    npm_ls
  end
  
  desc "Uninstall node"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if File.exist?('/usr/local/bin/node')
        # Remove all installed node modules and npm
        npm_list.each do |pkg|
          npm_uninstall pkg
        end
      
        npm_uninstall "npm"
      
        pkg_uninstall("org.nodejs")
      
        ["/usr/local/lib/node", "/usr/local/lib/node_modules"].each do |dir|
          sudo_remove_dir(dir)
        end
      else
        puts 'Node.js is not installed'
      end
    end
  end    
end
