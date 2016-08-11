# bzr tasks

namespace 'bzr' do
  desc 'Install bzr'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      # Install bzr from homebrew
      Bootstrap::MacOSX::Homebrew.install('bzr')
    end

    puts `bzr --version`
  end

  desc 'Uninstall bzr'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Homebrew.uninstall('bzr')
    end
  end
end
