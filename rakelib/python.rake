# Python tasks

PYTHON_27_PKG_NAME='python-2.7.11-macosx10.6'
PYTHON_27_PKG_ID=[
  'org.python.Python.PythonApplications-2.7',
  'org.python.Python.PythonDocumentation-2.7',
  'org.python.Python.PythonFramework-2.7',
  'org.python.Python.PythonUnixTools-2.7'
]
PYTHON_27_SRC_URL='https://www.python.org/ftp/python/2.7.11/python-2.7.11-macosx10.6.pkg'

PYTHON_35_PKG_NAME='python-3.5.1-macosx10.6'
PYTHON_35_PKG_ID=[
  'org.python.Python.PythonApplications-3.5',
  'org.python.Python.PythonDocumentation-3.5',
  'org.python.Python.PythonFramework-3.5',
  'org.python.Python.PythonUnixTools-3.5'
]
PYTHON_35_SRC_URL='https://www.python.org/ftp/python/3.5.1/python-3.5.1-macosx10.6.pkg'

PYTHON_PIP_PACKAGES=%w{virtualenv virtualenvwrapper}

namespace "python" do
  desc "Install Python 2.7"
  task :install27 do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(PYTHON_27_PKG_NAME, PYTHON_27_PKG_ID, PYTHON_27_SRC_URL)
    end
  end
  
  desc "Uninstall Python 2.7"
  task :uninstall27 do
  end

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

      PYTHON_PIP_PACKAGES.each { |p| Bootstrap::Pip.install(p, true) }
      
      unless File.exist?(virtualenv_root)
        puts "Creating #{virtualenv_root}"
        Dir.mkdir(virtualenv_root)
      end
    end

    desc "Uninstall virtualenv"
    task :uninstall do
      PYTHON_PIP_PACKAGES.each { |p| Bootstrap::Pip.uninstall(p, true) }
    end
  end
end



