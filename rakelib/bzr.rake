# bzr tasks

namespace "bzr" do
  desc "Install bzr"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install bzr from homebrew
      brew_install('bzr')
    end

    puts %x{bzr --version}
  end

  desc "Uninstall bzr"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      brew_uninstall('bzr')
    end
  end
end
