# Homebrew tasks

BREW_ROOT = '/opt/homebrew'
BREW_PATH_BIN = File.join(BREW_ROOT, 'bin')
BREW_PATH_MAN = [
      File.join(BREW_ROOT, 'share', 'man'),
      File.join(BREW_ROOT, 'manpages')
]

namespace 'homebrew' do
  desc 'Install Homebrew'
  task :install do
    raise('Homebrew already installed') if Dir.exist?(BREW_ROOT)

    Bootstrap.sudo_mkdir BREW_ROOT
    Bootstrap.sudo_chown BREW_ROOT
    Bootstrap.sudo_chgrp BREW_ROOT
    Bootstrap.sudo_chmod BREW_ROOT
    system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{BREW_ROOT}"
    MacOS.path_helper 'homebrew', BREW_PATH_BIN, 'paths'
    MacOS.path_helper 'homebrew', BREW_PATH_MAN, 'man'
  end

  desc 'Uninstall Homebrew'
  task :uninstall do
    raise('Homebrew not installed') unless Dir.exist?(BREW_ROOT)
    system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
    Bootstrap.sudo_rmdir BREW_ROOT
    ['paths', 'man'].each { |t| MacOS.rm_path_helper 'homebrew', t }
  end
end

module Homebrew
  module_function

  def prefix
    `brew --prefix`.strip
  end

  def command
    @cmd || File.join(prefix, 'bin', 'brew')
    raise 'Missing homebrew' unless @cmd
    @cmd
  end

  def install(formula)
    system "#{command} install #{formula}"
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

  def tap(repo)
    `#{command} tap #{repo}`
  end

  def untap(repo)
    `#{command} tap #{repo}`
  end

  module Cask
    module_function

    def install(cask)
      system "#{Homebrew.command} cask install #{cask}"
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
  end
end
