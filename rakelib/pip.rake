module Pip
  module_function

  def install(package, use_sudo = false)
    puts "Installing #{package}..."
    cmd = "pip install --upgrade #{package}"
    if use_sudo
      Bootstrap.sudo(cmd)
    else
      exec cmd
    end
  end

  def uninstall(package, use_sudo = false)
    puts "Uninstalling #{package}..."
    cmd = "pip uninstall --yes #{package}"
    if use_sudo
      Bootstrap.sudo(cmd)
    else
      exec cmd
    end
  end
end
