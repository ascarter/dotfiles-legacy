module Pip
  module_function

  def install(package, use_sudo = false)
    puts "Installing #{package}..."
    cmd = "pip install --upgrade #{package}"
    use_sudo ? sudo(cmd) : exec(cmd)
  end

  def uninstall(package, use_sudo = false)
    puts "Uninstalling #{package}..."
    cmd = "pip uninstall --yes #{package}"
    use_sudo ? sudo(cmd) : exec(cmd)
  end
end
