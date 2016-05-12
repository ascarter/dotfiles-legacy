# File and path helpers

require 'erb'
require 'fileutils'
require 'net/http'
require 'open-uri'
require 'open3'
require 'pathname'
require 'rake'
require 'tempfile'
require 'tmpdir'
require 'uri'

require_relative 'apm'
require_relative 'downloader'
require_relative 'git'
require_relative 'golang'
require_relative 'node'
require_relative 'pip'

case RUBY_PLATFORM
when /darwin/
  require_relative 'homebrew'
  require_relative 'macosx'
end

module Bootstrap
  # Helpers

  def macosx?
    return RUBY_PLATFORM =~ /darwin/
  end
  module_function :macosx?
  
  def linux?
    return RUBY_PLATFORM =~ /linux/
  end
  module_function :linux?
  
  def windows?
    return RUBY_PLATFORM =~ /windows/
  end
  module_function :windows?

  def prompt(message, default=nil)
      print "Enter #{message}#{" [#{default}]" unless nil}: "
      response = $stdin.gets.chomp
      return response.empty? ? default : response
  end
  module_function :prompt
  
  def home_dir
    return File.expand_path(ENV['HOME'])
  end
  module_function :home_dir

  def link_file(source, target)
    unless File.exist?(target)
      puts "Symlink #{source}"
      File.symlink(source, target)
    else
      puts "Symlink #{target} exists"
    end
  end
  module_function :link_file
  
  def backup(target)
    backup = "#{target}.orig"
    if File.exist?(target)
      puts "Backing up #{target} to #{backup}"
      File.rename(target, backup)
    end
  end
  module_function :backup
  
  def replace(source, target)
    backup(target)
    link_file(source, target)
  end
  module_function :replace
  
  def copy_and_replace(source, target)
    backup(target)
    FileUtils.copy(source, target)
  end
  module_function :copy_and_replace
  
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
  module_function :file_remove
  
  # sudo
  
  def sudo(cmd)
    system "sudo sh -c '#{cmd}'"
  end
  module_function :sudo

  def sudo_rm(target)
    if File.exist?(target) or File.symlink?(target) or File.directory?(target)
      puts "Removing #{target}"
      sudo "rm -f #{target}"
    end
  end
  module_function :sudo_rm

  def sudo_rmdir(target)
    if File.directory?(target)
      puts "Removing directory #{target}"
      sudo %Q{rm -Rf "#{target}"}
    end
  end
  module_function :sudo_rmdir
  
  def sudo_mkdir(path)
    unless File.exist?(path)
      puts "Creating #{path}"
      sudo "mkdir -p #{path}"
    end
  end
  module_function :sudo_mkdir  

  def sudo_cp(src, target)
    puts "Copying #{src} to #{target}"
    sudo %Q{cp "#{src}" "#{target}"}
  end
  module_function :sudo_cp
  
  def sudo_ln(src, target)
    if File.exists?(src)
      sudo %Q{ln -s "#{src}" "#{target}"}
    else
      warn "#{src} missing"
    end
  end
  module_function :sudo_ln
  
  def sudo_chgrp(path, group='admin')
    sudo "chgrp -R #{group} #{path}"
  end
  module_function :sudo_chgrp
  
  def sudo_chmod(path, mode='g+w')
    sudo "chmod #{mode} #{path}"
  end
  module_function :sudo_chmod

  # usr tools

  def usr_bin_cp(src, dest=nil)
    target = File.join('/usr/local/bin', dest.nil? ? File.basename(src) : dest)
    unless File.exist?(target)
      sudo_cp(src, target)
    else
      warn "#{target} already exists"
    end
  end
  module_function :usr_bin_cp
  
  def usr_bin_rm(cmd)
    cmd_file = File.join('/usr/local/bin', cmd)
    sudo_rm(cmd_file) if File.exist?(cmd_file)
  end
  module_function :usr_bin_rm
  
  def usr_bin_ln(src, target)
    src_file = File.expand_path(src)
    target_file = File.join('/usr/local/bin', target)
    unless File.exist?(target_file)
      sudo_ln(src_file, target_file)
    else
      warn "#{target} already exists"
    end
  end
  module_function :usr_bin_ln
end
