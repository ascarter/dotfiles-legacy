# Node.js tasks

namespace "node" do
    desc "Install node"
    task :install do
      if RUBY_PLATFORM =~ /darwin/
        # Install node.js from package
        unless File.exist?('/usr/local/bin/node')
          # TODO: Get list of releases and prompt user to pick
          release = 'v0.10.26'
          pkg = "node-#{release}.pkg"
          pkg_url = "http://nodejs.org/dist/#{release}/#{pkg}"
          pkg_download(pkg_url) do |p|
            pkg_install(p)
          end
        end
      end
      puts "Node.js: #{%x{/usr/local/bin/node --version}}"
      puts "npm:     #{%x{/usr/local/bin/npm --version}}"
      
      # Update npm
      npm_update
      
      # Install npm packages
      pkgs = %w{bower coffeelint grunt-cli jslint jsonlint}
      pkgs.each { |pkg| npm_install(pkg) }
      
      npm_list
    end
    
    
    
    desc "Uninstall node"
    task :uninstall do
      if RUBY_PLATFORM =~ /darwin/
        pkg_uninstall("org.nodejs")
        ["/usr/local/lib/node", "/usr/local/lib/node_modules"].each do |dir|
          sudo_remove_dir(dir)
        end
      end
    end    
end
