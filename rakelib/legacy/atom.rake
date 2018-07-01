# Atom tasks

ATOM_APP_NAME = 'Atom'.freeze
ATOM_SRC_URL = 'https://atom.io/download/mac'.freeze
# ATOM_PKGS = %w(dash go-plus go-debug native-ui nord-atom-syntax nord-atom-ui seti-syntax seti-ui sort-lines).freeze
ATOM_PKGS = %w(dash editorconfig native-ui sort-lines).freeze

namespace 'atom' do
  desc 'Install atom'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.install(ATOM_APP_NAME, ATOM_SRC_URL)

      # Install command line tools
      sh "open -a '#{ATOM_APP_NAME}'"
      puts 'To install command line tools, select Atom -> Install Shell Commands'

    when /linux/
      puts 'NYI: Install atom.x86_64 package'
    when /windows/
      puts 'NYI: Install via AtomSetup.exe'
    else
      raise 'Platform not supported'
    end
  end

  desc 'Install packages for atom'
  task :packages do
    ATOM_PKGS.each { |p| Bootstrap::APM.install(p) }
  end

  desc 'Uninstall atom'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # apm modules
      if File.exist? Bootstrap.usr_bin_cmd('apm')
        Bootstrap::APM.list.each { |p| Bootstrap::APM.uninstall(p) }
      end

      # Command line tools
      %w(atom apm).each { |c| Bootstrap.usr_bin_rm(c) }

      # Application
      MacOS::App.uninstall(ATOM_APP_NAME)
    end
  end
end
