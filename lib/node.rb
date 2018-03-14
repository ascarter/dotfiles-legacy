module Bootstrap
  # Node.js helpers
  module NodeJS
    def version
      puts "Node.js: #{`/usr/local/bin/node --version`}"
      puts "npm:     #{`/usr/local/bin/npm --version`}"
    end
    module_function :version
  end

  # NPM helpers
  module NPM
    def install(pkg)
      puts "Installing npm package #{pkg}..."
      Bootstrap.sudo "npm install --global #{pkg}"
    end
    module_function :install

    def update(pkg = '')
      puts "Updating npm package #{pkg}..."
      Bootstrap.sudo "npm update --global #{pkg}"
    end
    module_function :update

    def uninstall(pkg)
      puts "Uninstalling npm package #{pkg}..."
      Bootstrap.sudo "npm uninstall --global #{pkg}"
    end
    module_function :uninstall

    def installed?(pkg)
      _o, _e, s = Open3.capture3("npm list --global --parseable #{pkg}")
      s.exitstatus.zero?
    end
    module_function :installed?

    def list
      packages = []
      `npm list --global --parseable --depth=0`.split("\n").each do |pkg|
        pkg_name = File.basename(pkg)
        unless %w(lib npm).include?(pkg_name)
          packages.push(File.basename(pkg_name))
        end
      end
      packages
    end
    module_function :list

    def ls
      puts 'Installed npm modules:'
      list.each { |pkg| puts " #{pkg}" }
    end
    module_function :ls
  end
end
