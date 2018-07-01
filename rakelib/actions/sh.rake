module Actions
  module_function

  # Check if file exists. Useful for scripted install verification
  def check(args)
    raise "#{args} exists" if File.exist? args
  end

  # Change group
  def chgrp(args)
    Bootstrap.sudo_chgrp *args
  end

  # Change permissions
  def chmod(args)
    Bootstrap.sudo_chmod *args
  end

  # Change owner
  def chown(args)
    Bootstrap.sudo_chown *args
  end

  # List of hashes with src, target
  def cp(args)
    args.each { |v| Bootstrap.sudo_cp v['src'], v['target'] }
  end

  # Append to environment variable
  def env(args)
    args.each { |k, v| ENV[k] += ":#{v.join(':')}" }
  end

  # Make directory
  def mkdir(args)
    Bootstrap.sudo_mkdir args
  end

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

  # Execute shell script
  def sh(command)
    system command
  end

  # Execute shell script using sudo
  def sudo(args)
    Bootstrap.sudo args
  end

  # List of hashes with src, target
  def symlink(args)
    args.each { |v| Bootstrap.sudo_ln v['src'], v['target'] }
  end
end
