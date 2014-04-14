# require 'rake'
# require 'erb'
require 'fileutils'
require 'open-uri'
require 'pathname'
require 'uri'
require 'tmpdir'

def link_file(source, target)
  puts "Symlink #{source}"
  File.symlink(source, target)
end

def backup(target)
  backup = "#{target}.orig"
  if File.exist?(target)
    puts "Backing up #{target} to #{backup}"
    File.rename(target, backup)
  end
end

def replace(source, target)
  backup(target)
  link_file(source, target)
end

def copy_and_replace(source, target)
  backup(target)
  FileUtils.copy(source, target)
end

def file_remove(target)
  if File.exist?(target) or File.symlink?(target) or File.directory?(target)
    puts "Removing #{target}"
    File.delete(target)
  end
end

def sudo_remove(target)
  if File.exist?(target) or File.symlink?(target) or File.directory?(target)
    puts "Removing #{target}"
    sudo("rm -f #{target}")
  end
end

def prompt(message)
    print "Enter #{message}: "
    return $stdin.gets.chomp
end

def git_clone(owner, repo, dest=nil)
  git_url = URI.join("https://github.com/", "#{owner}/", "#{repo}.git").to_s
  cmd = "git clone #{git_url}"
  cmd += " #{dest.to_s}" if dest
  sh cmd
end

def git_pull(path)
  if File.directory?(path)
    sh "cd #{path} && git pull"
  end
end

def sudo(cmd)
  system "sudo sh -c '#{cmd}'"
end

def pip_install(package, use_sudo=false)
  puts "Installing #{package}..."
  cmd = "pip install --upgrade #{package}"
  if use_sudo
    sudo cmd
  else
    exec cmd
  end
end

def pip_uninstall(package, use_sudo=false)
  puts "Uninstalling #{package}..."
  cmd = "pip uninstall --yes #{package}"
  if use_sudo
    sudo cmd
  else
    exec cmd
  end
end

def path_helper(path_file, paths, type='paths')
  raise ArgumentError, "Invalid path type" unless ['paths', 'manpaths'].include? type

  fullpath = File.join("/etc/#{type}.d", path_file)
  unless File.exist?(fullpath)
    sudo "touch #{fullpath}"
    for path in paths
      sudo "echo '#{path}' >> #{fullpath}"
    end
  else
    puts "#{fullpath} already exists"
  end
end

def download_file(url, output)
  open(url) do |f|
    File.open(output, "wb") do |file|
      puts "Downloading #{url} to #{output}..."
      file.write(f.read)
    end
  end
end
