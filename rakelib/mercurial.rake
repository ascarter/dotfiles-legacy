# Mercurial tasks

namespace 'hg' do
  desc 'Install hg'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Homebrew.install('hg')
    end

    puts `hg --version`
  end

  desc 'Uninstall hg'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Homebrew.uninstall('hg')
    end
  end
end
