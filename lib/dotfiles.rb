require_relative 'dotfiles/apm'
require_relative 'dotfiles/archive'
require_relative 'dotfiles/downloader'
require_relative 'dotfiles/git'
require_relative 'dotfiles/go'
require_relative 'dotfiles/homebrew'
require_relative 'dotfiles/macos'
require_relative 'dotfiles/nodejs'
require_relative 'dotfiles/pip'
require_relative 'dotfiles/verification'

# Platform checks

def macOS?
  RUBY_PLATFORM =~ /darwin/
end

def linux?
  RUBY_PLATFORM =~ /linux/
end

def windows?
  RUBY_PLATFORM =~ /windows/
end

def require_macOS
  raise 'macOS required' unless macOS?
end

def require_linux
  raise 'Linux required' unless linux?
end

def require_windows
  raise 'Windows required' unless windows?
end

def prompt(message, default = nil)
  print "Enter #{message}#{" [#{default}]" unless default.nil?}: "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end

def prompt_to_continue
  puts 'Press any key to continue'
  STDIN.getch
  puts "\n"
end

# user

def home_dir
  File.expand_path(ENV['HOME'])
end

def ssh_dir
  File.expand_path(File.join(home_dir, '.ssh'))
end

def config_dir
  File.expand_path(File.join(home_dir, '.config'))
end

def library_dir
  File.expand_path(File.join(home_dir, 'Library'))
end

def current_user
  Etc.getlogin
end

def user_info(user = Etc.getlogin)
  Etc.getpwnam(user)
end

# sudo

def sudo(cmd)
  system "sudo sh -c '#{cmd}'"
end

def sudo_rm(target)
  if File.exist?(target) || File.symlink?(target) || File.directory?(target)
    puts "Removing #{target}"
    sudo "rm -f #{target}"
  end
end

def sudo_rmdir(target)
  if File.directory?(target)
    puts "Removing directory #{target}"
    sudo %(rm -Rf "#{target}")
  end
end

def sudo_mkdir(path)
  unless File.exist?(path)
    puts "Creating #{path}"
    sudo "mkdir -p #{path}"
  end
end

def sudo_cp(src, target)
  if File.exist?(target)
    warn "#{target} already exists"
  else
    puts "Copying #{src} to #{target}"
    sudo %(cp "#{src}" "#{target}")
  end
end

def sudo_cpr(src, target)
  puts "Copying #{src} to #{target}"
  sudo %(cp -R "#{src}" "#{target}")
end

def sudo_ln(src, target)
  src_file = File.expand_path(src)
  target_file = File.expand_path(target)
  if File.exist?(target_file)
    warn "#{target} already exists"
  elsif File.exist?(src_file)
    sudo %(ln -s "#{src_file}" "#{target_file}")
  else
    warn "#{src} missing"
  end
end

def sudo_chgrp(path, group = 'admin')
  sudo %(chgrp -R #{group} "#{path}")
end

def sudo_chmod(path, mode = 'g+w')
  sudo %(chmod #{mode} "#{path}")
end

def sudo_chown(path, owner = current_user)
  sudo %(chown -R #{owner} "#{path}")
end

