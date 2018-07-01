module Bootstrap
  case RUBY_PLATFORM
  when /darwin/
    # Homebrew helpers
    module Homebrew
      def command
        @cmd ||= File.join(prefix, 'bin', 'brew')
        raise Exception 'Missing homebrew' unless @cmd
        @cmd
      end
      module_function :command

      def prefix
        `brew --prefix`.strip
      end
      module_function :prefix

      def bin_path(cmd)
        File.join(prefix, 'bin', cmd)
      end
      module_function :bin_path

      def update
        system "#{command} update"
      end
      module_function :update

      def install(package, args = nil)
        # Check if package installed already
        if installed?(package)
          # Package is installed - update it if outdated
          upgrade(package, args)
        else
          # Install package
          puts "Install homebrew #{package}"
          system "#{command} install #{args unless args.nil?} #{package}"
        end
      end
      module_function :install

      def uninstall(package)
        if installed?(package)
          puts "Uninstall homebrew #{package}"
          system "#{command} uninstall #{package}"
        end
      end
      module_function :uninstall

      def outdated(package)
        `#{command} outdated --quiet`.include?(package)
      end
      module_function :outdated

      def upgrade(package = nil, args = nil)
        if !package.nil? && !outdated(package)
          warn "#{package} is up to date"
        else
          system "#{command} upgrade --cleanup #{args unless args.nil?} #{package unless package.nil?}"
        end
      end
      module_function :upgrade

      def installed?(package)
        system("#{command} list #{package} > /dev/null 2>&1")
      end
      module_function :installed?

      def list
        `#{command} list`
      end
      module_function :list

      def info(package)
        `#{command} info #{package}`
      end
      module_function :info

      def tap(package)
        system "#{command} tap #{package}"
      end
      module_function :tap

      def untap(package)
        system "#{command} untap #{package}"
      end
      module_function :untap
    end
  end
end
