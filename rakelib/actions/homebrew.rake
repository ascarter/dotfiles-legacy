module Actions
  module Homebrew
    module_function

    # Install homebrew formula/tap
    def install(args)
      Homebrew.update
      args.each do |k, v|
        case k
        when 'tools'
          v.each { |t| Homebrew.install t }
        when 'taps'
          v.each do |t|
            parts = t.split('/')
            Homebrew.tap(t)
            Homebrew.install(parts[1], '--HEAD')
          end
        when 'overrides'
          v.each { |o| Bootstrap.usr_bin_ln(Homebrew.bin_path(o), o) }
        end
      end
    end

    # Uninstall homebrew formula/tap
    def uninstall(args)
      args.each do |k, v|
        case k
        when 'tools'
          v.each { |t| Homebrew.uninstall t }
        when 'taps'
          v.each { |t| Homebrew.untap t }
        when 'overrides'
          v.each { |o| Bootstrap.usr_bin_rm o }
        end
      end
    end
  end
end

# Homebrew helpers

module Homebrew
  module_function

  def command
    @cmd ||= File.join(prefix, 'bin', 'brew')
    raise Exception 'Missing homebrew' unless @cmd
    @cmd
  end

  def prefix
    `brew --prefix`.strip
  end

  def bin_path(cmd)
    File.join(prefix, 'bin', cmd)
  end

  def update
    system "#{command} update"
  end

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

  def uninstall(package)
    if installed?(package)
      puts "Uninstall homebrew #{package}"
      system "#{command} uninstall #{package}"
    end
  end

  def outdated(package)
    `#{command} outdated --quiet`.include?(package)
  end

  def upgrade(package = nil, args = nil)
    if !package.nil? && !outdated(package)
      warn "#{package} is up to date"
    else
      system "#{command} upgrade --cleanup #{args unless args.nil?} #{package unless package.nil?}"
    end
  end

  def installed?(package)
    system("#{command} list #{package} > /dev/null 2>&1")
  end

  def list
    `#{command} list`
  end

  def info(package)
    `#{command} info #{package}`
  end

  def tap(package)
    system "#{command} tap #{package}"
  end

  def untap(package)
    system "#{command} untap #{package}"
  end
end
