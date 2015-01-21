require 'fileutils'
require 'net/http'
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
  if File.exist?(target) and File.directory?(target)
    puts "Removing directory #{target}"
    FileUtils.remove_dir(target)
  elsif File.exist?(target) or File.symlink?(target)
    puts "Removing #{target}"
    File.delete(target)
  else
    puts "File #{target} not found"
  end
end

def prompt(message)
    print "Enter #{message}: "
    return $stdin.gets.chomp
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

def download(response, dest)
  Thread.new do
    thread = Thread.current
    length = thread[:length] = response['Content-Length'].to_i
    open(dest, 'wb') do |io|
      response.read_body do |fragment|
        thread[:done] = (thread[:done] || 0) + fragment.length 
        thread[:progress] = thread[:done].quo(length) * 100
        io.write fragment
      end
    end
  end
end

def fetch(url, dest, limit = 10)
  raise "Too many redirects" if limit == 0

  puts "Fetching #{url}"
  uri = URI(url)
  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new uri
    http.request request do |response|
      case response
      when Net::HTTPSuccess then
        thread = download(response, dest)
        print "\rDownloading #{File.basename dest}: %d%%" % thread[:progress].to_i until thread.join 1
        puts ""
      when Net::HTTPRedirection then
        location = response['location']
        warn "  --> redirected to #{location}"
        fetch(location, dest, limit - 1)
      else
        raise "#{response.class.name} #{res.code} #{res.message}"
      end
    end
  end
end

def unzip(zipfile)
  system "unzip #{zipfile} -d #{File.dirname(zipfile)}" 
end


#
# sudo
#

def sudo(cmd)
  system "sudo sh -c '#{cmd}'"
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


#
# git
#

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

def git_config(key, value)
  sh "git config --global #{key} \"#{value}\""
end

#
# pip
#

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


#
# homebrew
#

def brew_command
  @brew_cmd ||= %x{which brew}.strip()
  if not @brew_cmd
    raise Exception "Missing homebrew"
  end
  return @brew_cmd
end

def brew_update
  sudo "#{brew_command} update"
end

def brew_install(package)
  # Check if package installed already
  if brew_list(package)
    # Package is installed - update it if outdated
    brew_upgrade(package)
  else
    # Install package
    sudo "#{brew_command} install #{package}"
  end
end

def brew_uninstall(package)
  if brew_list(package)
    sudo "#{brew_command} uninstall #{package}"
  end
end

def brew_outdated(package)
  outdated_packages = %x{#{brew_command} outdated --quiet}

  if outdated_packages.include?(package)
    return true
  else
    return false
  end
end

def brew_upgrade(package)
  if brew_outdated(package)
    sudo "#{brew_command} upgrade #{package}"
  else
    puts "#{package} is up to date"
  end
end

def brew_list(package)
  return system("#{brew_command} list #{package} > /dev/null 2>&1")
end


#
# Mac OS X package installer
#

def pkg_download(url)
  uri = URI.parse(url)
  (path, pkg) = File.split(uri.path)
  Dir.mktmpdir do |dir|
    pkg_path = File.join(dir, pkg)
    fetch(url, pkg_path)
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

  # Remove plist or bom files
  ['.plist', '.bom'].each do |ext|
    sudo_remove(File.join(receipts_path, pkg + ext))
  end
end

def dmg_mount(dmg)
  return %x{hdiutil attach "#{dmg}" | tail -1 | awk '{$1=$2=""; print $0}' | xargs -0 echo}.strip!
end

def dmg_unmount(dmg)
  sh "hdiutil detach \"#{dmg}\""
end

def install_app(app)
  sudo "cp -R \"#{app}\" /Applications/."
end

def run_applescript(script)
  sh "osascript \"#{script}\""
end

def hide_app(app)
  script = "tell application \"Finder\" to set visible of process \"#{app}\" to false"
  sh "osascript -e '#{script}'"
end


#
# go
#

def go_get(pkg)
  cmd = "go get -u #{pkg}"
  puts cmd
  system cmd
end

#
# npm
#

def node_version
  puts "Node.js: #{%x{/usr/local/bin/node --version}}"
  puts "npm:     #{%x{/usr/local/bin/npm --version}}"
end

def npm_install(pkg)
  if %x{npm list --global --parseable #{pkg}}.strip().empty?
    sudo "npm install --global #{pkg}"
  else
    puts "#{pkg} already installed"
  end
end

def npm_update(pkg="")
  sudo "npm update --global #{pkg}"
end

def npm_uninstall(pkg)
  sudo "npm uninstall --global #{pkg}"
end

def npm_list
  packages = []
  %x{npm list --global --parseable --depth=0}.split("\n").each do |pkg|
    pkg_name = File.basename(pkg)
    unless %w{lib npm}.include?(pkg_name)
      packages.push(File.basename(pkg_name))
    end
  end
  return packages
end

def npm_ls
  puts "Installed npm modules:"
  npm_list.each { |pkg| puts "  #{pkg}" }
end

#
# Mac OS X defaults
#

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
