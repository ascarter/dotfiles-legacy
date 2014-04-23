require 'fileutils'
require 'open-uri'
require 'pathname'
require 'tempfile'
require 'uri'

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
  else
    puts "File #{target} not found"
  end
end

def sudo_remove(target)
  if File.exist?(target) or File.symlink?(target) or File.directory?(target)
    puts "Removing #{target}"
    sudo("rm -f #{target}")
  end
end

def sudo_remove_dir(target)
  if File.directory?(target)
    puts "Removing directory #{target}"
    sudo("rm -Rf #{target}")
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
  puts "Downloading #{url} to #{output}..."
  open(url) do |f|
    File.open(output, "wb") do |file|
      file.write(f.read)
    end
  end
end

# Mac OS X package installer

def pkg_download(url)
  uri = URI.parse(url)
  (path, pkg) = File.split(uri.path)
  Dir.mktmpdir do |dir|
    pkg_path = File.join(dir, pkg)
    download_file(url, pkg_path)
    yield pkg_path
  end
end

def pkg_install(pkg)
  if File.exist?(pkg)
    sudo "installer -pkg #{pkg} -target /"
  else
    puts "Package #{pkg} missing"
  end
end

def pkg_uninstall(pkg, prefix='/usr/local')
  receipts_path = '/var/db/receipts'
  bom = File.join(receipts_path, pkg + '.pkg.bom')
  if File.exist?(bom)
    # Remove files
    %x{lsbom -f -l -s -pf #{bom}}.each_line do |file|
      path = File.expand_path(File.join(prefix, file.strip))
      sudo_remove(path)
    end
    Dir.glob(File.join(receipts_path, pkg + '.*')).each do |file|
      sudo_remove(file)
    end
  else
    puts "Package #{bom} is not installed"
  end
end

# npm

def npm_install(pkg)
  if %x{npm list --global --parseable #{pkg}}
    puts "#{pkg} already installed"
  else
    sudo "npm install --global #{pkg}"
  end
end

def npm_update(pkg="")
  sudo "npm update --global #{pkg}"
end

def npm_uninstall(pkg)
  sudo "npm uninstall --global #{pkg}"  
end

def npm_list(pkg="", depth=0)
  sudo "npm list --global --depth=#{depth} #{pkg}"
end

# Mac OS X defaults

def defaults_read(domain, key=nil, options=nil)
  value = %x{defaults read #{domain} #{options} #{"\"#{key}\"" unless key.nil?}}
  return value
end

def defaults_write(domain, key, value, options=nil)
  %x{defaults write #{domain} "#{key}" #{options} "#{value}"}
end

def defaults_delete(domain, key, options=nil)
  %x{defaults delete #{domain} "#{key}" #{options}}
end