# Python virtualenv tasks

namespace "virtualenv" do
  desc "Install virtualenv"
  task :install do
    virtualenv_root = File.expand_path("~/.virtualenvs")

    unless File.exist?('/usr/local/bin/pip')
      puts "Install pip..."
      sudo "easy_install --upgrade pip"
    end

    pip_install("virtualenv", true)
    pip_install("virtualenvwrapper", true)

    unless File.exist?(virtualenv_root)
      puts "Creating #{virtualenv_root}"
      Dir.mkdir(virtualenv_root)
    end
  end

  desc "Uninstall virtualenv"
  task :uninstall do
    pip_uninstall("virtualenv", true)
    pip_uninstall("virtualenvwrapper", true)
  end
end
