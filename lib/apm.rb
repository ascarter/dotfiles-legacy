#
# apm (atom package manager)
#

module Bootstrap
  # Atom package manager
  module APM
    def install(pkg)
      if list.include?(pkg)
        puts "#{pkg} already installed"
      else
        system "apm install #{pkg}"
      end
    end
    module_function :install

    def upgrade
      system 'apm upgrade --confirm false'
    end

    def uninstall(pkg)
      system "apm uninstall #{pkg}" if list.include?(pkg)
    end
    module_function :uninstall

    def list
      packages = []
      `apm list --installed --bare`.split.each do |p|
        (name, _version) = p.split('@')
        packages.push(name)
      end
      packages
    end
    module_function :list
  end
end
