# Node.js / NPM helpers

module Bootstrap
  module NodeJS
    def version
      puts "Node.js: #{%x{/usr/local/bin/node --version}}"
      puts "npm:     #{%x{/usr/local/bin/npm --version}}"
    end
    module_function :version
  end

  module NPM
    def install(pkg)
      if %x{npm list --global --parseable #{pkg}}.strip().empty?
        sudo "npm install --global #{pkg}"
      else
        puts "#{pkg} already installed"
      end
    end
    module_function :install

    def update(pkg="")
      sudo "npm update --global #{pkg}"
    end
    module_function :update

    def uninstall(pkg)
      sudo "npm uninstall --global #{pkg}"
    end
    module_function :uninstall

    def list
      packages = []
      %x{npm list --global --parseable --depth=0}.split("\n").each do |pkg|
        pkg_name = File.basename(pkg)
        unless %w{lib npm}.include?(pkg_name)
          packages.push(File.basename(pkg_name))
        end
      end
      return packages
    end
    module_function :list

    def ls
      puts "Installed npm modules:"
      npm_list.each { |pkg| puts " #{pkg}" }
    end
    module_function :ls
  end
end
