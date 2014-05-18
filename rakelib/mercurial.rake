# Mercurial tasks

namespace "hg" do
  desc "Install hg"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install bzr from homebrew
      brew_install('hg')
    end

    puts %x{hg --version}
  end

  desc "Uninstall hg"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      brew_uninstall('hg')
    end
  end
end
