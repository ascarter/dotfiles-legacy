#
# homebrew helpers
#

module HomeBrew
  def command
    @cmd ||= File.join(prefix, 'bin', 'brew')
    if not @cmd
      raise Exception "Missing homebrew"
    end
    return @cmd
  end
  module_function :command

  def prefix
    %x{brew --prefix}.strip()
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

  def install(package, args=nil)
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
    outdated_packages = %x{#{command} outdated --quiet}

    if outdated_packages.include?(package)
      return true
    else
      return false
    end
  end
  module_function :outdated

  def upgrade(package, args=nil)
    if outdated(package)
      system "#{command} upgrade #{args unless args.nil?} #{package}"
    else
      puts "#{package} is up to date"
    end
  end
  module_function :upgrade

  def installed?(package)
    return system("#{command} list #{package} > /dev/null 2>&1")
  end
  module_function :installed?
  
  def list
    return %x{#{command} list}
  end
  module_function :list
  
  def info(package)
    return %x{#{command} info #{package}}
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