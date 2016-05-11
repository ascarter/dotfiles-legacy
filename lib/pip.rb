#
# pip helpers
#

module Pip
  def install(package, use_sudo=false)
    puts "Installing #{package}..."
    cmd = "pip install --upgrade #{package}"
    if use_sudo
      sudo cmd
    else
      exec cmd
    end
  end
  module_function :install

  def uninstall(package, use_sudo=false)
    puts "Uninstalling #{package}..."
    cmd = "pip uninstall --yes #{package}"
    if use_sudo
      sudo cmd
    else
      exec cmd
    end
  end
  module_function :uninstall
end