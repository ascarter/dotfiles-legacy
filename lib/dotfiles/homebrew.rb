module Homebrew
  module_function

  def collection(taps: [], pkgs: [], casks: [])
    taps.each { |t| tap t }
    pkgs.each { |p| install p }
    casks.each { |c| Cask.install c }
  end

  def prefix(pre)
    @prefix = pre
  end

  def command
    @cmd ||= File.join(@prefix || `brew --prefix`.strip, 'bin', 'brew')
  end

  def install(formula)
    system "#{command} install #{formula}" unless installed?(formula)
  end

  def update
    system "#{command} update"
  end

  def upgrade
    system "#{command} upgrade #{formula}"
  end

  def uninstall(formula)
    system "#{command} uninstall --force #{formula}"
  end

  def list
    `#{command} list`.split
  end

  def installed?(formula)
    system("#{command} list #{formula}", out: File::NULL, err: File::NULL)
  end

  def tap(repo)
    `#{command} tap #{repo}` unless tap_installed?(repo)
  end

  def untap(repo)
    `#{command} tap #{repo}`
  end

  def tap_installed?(repo)
    system("#{command} tap | grep #{repo}", out: File::NULL, err: File::NULL)
  end

  module Cask
    module_function

    def install(cask)
      system "#{Homebrew.command} cask install #{cask}" unless installed?(cask)
    end

    def upgrade(cask)
      system "#{Homebrew.command} cask upgrade #{cask}"
    end

    def uninstall(cask)
      system "#{Homebrew.command} cask uninstall #{cask}"
    end

    def list
      `#{Homebrew.command} cask list`.split
    end

    def installed?(cask)
      system("#{Homebrew.command} cask list #{cask}", out: File::NULL, err: File::NULL)
    end
  end
end
