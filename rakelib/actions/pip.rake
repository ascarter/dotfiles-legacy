module Actions
  module Pip
    module_function

    # pip install
    def install(args)
      args.each { |p| Pip.install p }
    end

    # pip uninstall
    def uninstall(args)
      args.each { |p| Pip.uninstall p }
    end
  end
end

# pip helpers

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
