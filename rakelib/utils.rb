require 'fileutils'
require 'net/http'
require 'open-uri'
require 'open3'
require 'pathname'
require 'tempfile'
require 'uri'

def home_dir
  return File.expand_path(ENV['HOME'])
end

def link_file(source, target)
  unless File.exist?(target)
    puts "Symlink #{source}"
    File.symlink(source, target)
  else
    puts "Symlink #{target} exists"
  end
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

def prompt(message, default=nil)
    print "Enter #{message}#{" [#{default}]" unless nil}: "
    response = $stdin.gets.chomp
    return response.empty? ? default : response
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
        raise "#{response.class.name} #{response.code} #{response.message}"
      end
    end
  end
end

def unzip(zipfile, exdir=nil)
  exdir = File.dirname(zipfile) if exdir.nil?
  system "unzip -q #{zipfile} -d #{exdir}"
end

def run_applescript(script)
  system "osascript \"#{script}\""
end


#
# usr tools
#

def usr_bin_cp(src)
  cmd_file = File.join('usr/local/bin', File.basename(src))
  unless File.exist?(cmd_file)
    sudo "cp #{src} /usr/local/bin."
  else
    puts "#{cmd_file} already exists"
  end
end

def usr_bin_rm(cmd)
  sudo_remove(File.join('/usr/local/bin', cmd))
end

def usr_bin_ln(src, target)
  src_file = File.expand_path(src)
  target_file = File.join('/usr/local/bin', target)
  unless File.exist?(target_file)
    sudo "ln -s #{src_file} #{target_file}" if File.exists?(src_file)
  end
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

def git_clone(repo, dest=nil)
  git_url = URI.join("https://github.com/", "#{repo}.git").to_s
  cmd = "git clone #{git_url}"
  cmd += " #{dest.to_s}" if dest
  system cmd
end

def git_pull(path)
  if File.directory?(path)
    system "cd #{path} && git pull"
  end
end

def git_config(key, value)
  system "git config --global #{key} \"#{value}\""
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
  system "#{brew_command} update"
end

def brew_install(package)
  # Check if package installed already
  if brew_list(package)
    # Package is installed - update it if outdated
    brew_upgrade(package)
  else
    # Install package
    system "#{brew_command} install #{package}"
  end
end

def brew_uninstall(package)
  if brew_list(package)
    system "#{brew_command} uninstall #{package}"
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
    system "#{brew_command} upgrade #{package}"
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

def pkg_ls(pkg)
  if system "pkgutil --pkgs=\"#{pkg.gsub(".", "\.")}\""
    files = %x{pkgutil --only-files --files #{pkg}}
    dirs = %x{pkgutil --only-dirs --files #{pkg}}
    return files.split, dirs.split
  else
    puts "Package #{pkg} not installed"
  end
end

def pkg_info(pkg)
  info = {}
  o, s = Open3.capture2("pkgutil --pkg-info #{pkg}")
  return nil unless s.success?
  o.each_line do |l|
    parts = l.split(':')
    info[parts[0].strip] = parts[1].strip
  end
  return info
end

def pkg_install(pkg)
  if File.exist?(pkg)
    sudo "installer -package #{pkg} -target /"
  end
end

def pkg_uninstall(pkg, dryrun=false)
  info = pkg_info(pkg)
  puts "Pkg info: #{info}" if dryrun

  if info
    files, dirs = pkg_ls(pkg)

    # Remove files
    files.each do |f|
      path = File.expand_path(File.join(info["volume"], info["location"], f))
      sudo_remove(path) unless dryrun
    end

    # Forget package
    sudo "pkgutil --forget #{pkg}" unless dryrun

    # Don't remove directories - this needs to be per package so return them
    return dirs
  else
    puts "Package #{pkg} is not installed"
  end
end

def dmg_mount(dmg)
  return %x{hdiutil attach "#{dmg}" | tail -1 | awk '{$1=$2=""; print $0}' | xargs -0 echo}.strip!
end

def dmg_unmount(dmg)
  system "hdiutil detach \"#{dmg}\""
end

def app_path(app)
  return File.join('/Applications', "#{app}.app")
end

def app_exists(app)
  path = app_path(app)
  return File.exist?(path)
end

def app_install(app)
  path = app_path(File.basename(app, ".app"))
  unless File.exist?(path)
    puts "Installing #{app} to #{path}"
    sudo "ditto \"#{app}\" \"#{path}\""
  end
end

def app_remove(app)
  path = app_path(app)
  if File.Exist?(path)
    sudo_remove_dir path
  end
end

def app_hide(app)
  script = "tell application \"Finder\" to set visible of process \"#{app}\" to false"
  system "osascript -e '#{script}'"
end


#
# go
#

def go_get(workspace, pkg)
  ENV['GOPATH'] = workspace
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
# apm (atom package manager)
#

def apm_install(pkg)
  unless apm_list().include?(pkg)
    system "apm install #{pkg}"
  else
    puts "#{pkg} already installed"
  end
end

def apm_upgrade
  system "apm upgrade --confirm false"
end

def apm_uninstall(pkg)
  system "apm uninstall #{pkg}" if apm_list().include?(pkg)
end

def apm_list
  packages = []
  %x{apm list --installed --bare}.split.each do |p|
    (name, version) = p.split('@')
    packages.push(name)
  end
  return packages
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

def defaults_delete(domain, key=nil, options=nil)
  cmd = "defaults delete #{domain}"
  %x{defaults delete #{domain} #{"#{key}" unless key.nil?} #{options}}
end
