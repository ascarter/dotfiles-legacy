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
      if !installed?(pkg)
        Bootstrap.sudo "npm install --global #{pkg}"
      else
        warn "#{pkg} already installed"
      end
    end
    module_function :install

    def update(pkg = '')
      Bootstrap.sudo "npm update --global #{pkg}"
    end
    module_function :update

    def uninstall(pkg)
      if installed?(pkg)
        Bootstrap.sudo "npm uninstall --global #{pkg}"
      else
        warn "#{pkg} is not installed"
      end
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

  # Yarn helpers
  module Yarn
    def install(pkg)
      if !installed?(pkg)
        Bootstrap.sudo "yarn global add #{pkg}"
      else
        warn "#{pkg} already installed"
      end
    end
    module_function :install

    def update(pkg = '')
      Bootstrap.sudo "yarn global update #{pkg}"
    end
    module_function :update

    def uninstall(pkg)
      if installed?(pkg)
        Bootstrap.sudo "yarn global remove #{pkg}"
      else
        warn "#{pkg} is not installed"
      end
    end
    module_function :uninstall

    def installed?(pkg)
    	list.each do |p|
    		return true if pkg == p.split('@')[0]
    	end
    	return false
    end
    module_function :installed?

    def list
      packages = []
      `sudo yarn global ls --no-emoji --no-progress 2>&1`.split("\n").each do |line|
      	line.match(/^info "(\S+)"/) do |m|
      		packages.push(m[1])
      	end
      end
      packages
    end
    module_function :list

    def ls
      puts 'Installed global yarn modules:'
      list.each { |pkg| puts " #{pkg}" }
    end
    module_function :ls
  end
end
