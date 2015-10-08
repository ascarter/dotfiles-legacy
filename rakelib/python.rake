# Python tasks

namespace "python" do
#   desc "Install python"
#   task :install do
#   end
#   
#   desc "Uninstall python"
#   task :uninstall do
#   end

  namespace "pip" do
    desc "Install pip"
    task :install do
      getpip = 'https://bootstrap.pypa.io/get-pip.py'
      sudo "curl #{getpip} | python"
    end
    
    desc "Uninstall pip"
    task :uninstall do
    
    end
  end

  namespace "virtualenv" do
    desc "Install virtualenv"
    task :install do
      virtualenv_root = File.expand_path("~/.virtualenvs")

      unless File.exist?('/usr/local/bin/pip')
        puts "Pip not installed"
        exit
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
end



