module Actions
  # Check if file exists. Useful for scripted install verification
  def check(args)
    raise "#{args} exists" if File.exist? args
  end
  module_function :check

  # Change group
  def chgrp(args)
    Bootstrap.sudo_chgrp *args
  end
  module_function :chgrp

  # Change permissions
  def chmod(args)
    Bootstrap.sudo_chmod *args
  end
  module_function :chmod

  # Change owner
  def chown(args)
    Bootstrap.sudo_chown *args
  end
  module_function :chown

  # List of hashes with src, target
  def cp(args)
    args.each { |v| Bootstrap.sudo_cp v['src'], v['target'] }
  end
  module_function :cp

  # Append to environment variable
  def env(args)
    args.each { |k, v| ENV[k] += ":#{v.join(':')}" }
  end
  module_function :env

  # Make directory
  def mkdir(args)
    Bootstrap.sudo_mkdir args
  end
  module_function :mkdir

  # Remove list of files
  def rm(args)
    args.each do |target|
      if File.directory?(target)
        Bootstrap.sudo_rmdir target
      else
        Bootstrap.sudo_rm target
      end
    end
  end
  module_function :rm

  # Execute shell script
  def shell(command)
    system command
  end
  module_function :shell

  # Execute shell script using sudo
  def sudo(args)
    Bootstrap.sudo args
  end
  module_function :sudo

  # List of hashes with src, target
  def symlink(args)
    args.each { |v| Bootstrap.sudo_ln v['src'], v['target'] }
  end
  module_function :symlink
end
