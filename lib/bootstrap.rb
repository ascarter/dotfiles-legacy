# File and path helpers

require 'digest'
require 'erb'
require 'etc'
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
require_relative 'archive'
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

# Bootstrap contains the support system for the dotfiles system
module Bootstrap
  # bootstrap links all the files in src to same file at dest
  # If sparse is set to true, recursively scan source directories and only link files
  def bootstrap(src, dest, sparse = false)
    replace_all = false

    src_dir = Pathname.new(src).expand_path
    dest_dir = Pathname.new(dest).expand_path

    # Ensure that the target exists
    dest_dir.mkpath

    Dir.glob(src_dir.join(sparse ? "**/*" : "*"), File::FNM_DOTMATCH).each do |f|
      source = Pathname.new(f)
      target = dest_dir.join(source.relative_path_from(src_dir))

      next if %w(. .. .DS_Store).include?(source.basename.to_s)
      next if source.directory? and sparse

      if target.exist? or target.symlink? or target.directory?
        if File.identical?(source, target)
          puts "Identical #{source}"
        else
          puts 'Diff:'
          system %Q{diff "#{source}" "#{target}"}
          if replace_all
            Bootstrap.replace(source, target)
          else
            print "Replace existing file #{source}? [ynaq] "
            case $stdin.gets.chomp
            when 'a'
              replace_all = true
              replace(source, target)
            when 'y'
              replace(source, target)
            when 'q'
              warn 'Abort'
              exit
            else
              puts "Skipping #{source}"
            end
          end
        end
      else
        link_file(source, target)
      end
    end
  end
  module_function :bootstrap

  def unbootstrap(src, dest, sparse = false)
    src_dir = Pathname.new(src).expand_path
    dest_dir = Pathname.new(dest).expand_path

    Dir.glob(src_dir.join(sparse ? "**/*" : "*"), File::FNM_DOTMATCH).each do |f|
      source = Pathname.new(f)
      target = dest_dir.join(source.relative_path_from(src_dir))

      next if %w(. ..).include?(source.basename.to_s)
      next if source.directory? and sparse

      Bootstrap.file_remove(target)
    end
  end
  module_function :unbootstrap

  # Helpers

  def macosx?
    RUBY_PLATFORM =~ /darwin/
  end
  module_function :macosx?

  def linux?
    RUBY_PLATFORM =~ /linux/
  end
  module_function :linux?

  def windows?
    RUBY_PLATFORM =~ /windows/
  end
  module_function :windows?

  def about(title, description='', homepage='')
    puts "#{title}"
    puts "#{description}"
    puts "#{homepage}"
  end
  module_function :about

  def prompt(message, default = nil)
    print "Enter #{message}#{" [#{default}]" unless default.nil?}: "
    response = $stdin.gets.chomp
    response.empty? ? default : response
  end
  module_function :prompt

  def home_dir
    File.expand_path(ENV['HOME'])
  end
  module_function :home_dir

  def config_dir
    File.expand_path(File.join(home_dir, '.config'))
  end
  module_function :config_dir

  def library_dir
    File.expand_path(File.join(home_dir, 'Library'))
  end
  module_function :library_dir

  def workspace_dir
    File.join(Bootstrap.home_dir, 'Projects')
  end
  module_function :workspace_dir

  def current_user
    Etc.getlogin
  end
  module_function :current_user

  def user_info(user = Etc.getlogin)
    Etc.getpwnam(user)
  end
  module_function :user_info

  def link_file(source, target)
    if File.exist?(target)
      puts "Symlink #{target} exists"
    else
      puts "Symlink #{source}"
      File.symlink(source, target)
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
    if File.exist?(target) && File.directory?(target)
      puts "Removing directory #{target}"
      FileUtils.remove_dir(target)
    elsif File.exist?(target) || File.symlink?(target)
      puts "Removing #{target}"
      File.delete(target)
    else
      puts "File #{target} not found"
    end
  end
  module_function :file_remove

  def font_dir
    case RUBY_PLATFORM
    when /darwin/
      return File.join(home_dir, 'Library', 'Fonts')
    end
  end
  module_function :font_dir

  # shell

  def system_echo(cmd)
    puts cmd
    Open3.popen2e(cmd) do |i, oe, t|
      oe.each { |line| puts line }
      unless t.value.success?
        abort "FAILED: #{cmd}"
      end
    end
  end
  module_function :system_echo

  # sudo

  def sudo(cmd)
    system "sudo sh -c '#{cmd}'"
  end
  module_function :sudo

  def sudo_rm(target)
    if File.exist?(target) || File.symlink?(target) || File.directory?(target)
      puts "Removing #{target}"
      sudo "rm -f #{target}"
    end
  end
  module_function :sudo_rm

  def sudo_rmdir(target)
    if File.directory?(target)
      puts "Removing directory #{target}"
      sudo %(rm -Rf "#{target}")
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
    sudo %(cp "#{src}" "#{target}")
  end
  module_function :sudo_cp

  def sudo_cpr(src, target)
    puts "Copying #{src} to #{target}"
    sudo %(cp -R "#{src}" "#{target}")
  end
  module_function :sudo_cpr

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
  module_function :sudo_ln

  def sudo_chgrp(path, group = 'admin')
    sudo %(chgrp -R #{group} "#{path}")
  end
  module_function :sudo_chgrp

  def sudo_chmod(path, mode = 'g+w')
    sudo %(chmod #{mode} "#{path}")
  end
  module_function :sudo_chmod

  def sudo_chown(path, owner = current_user)
    sudo %(chown -R #{owner} "#{path}")
  end
  module_function :sudo_chown

  # usr tools

  # usr_dir returns directory for /usr/<dir>
  def usr_dir(dir = 'bin')
    File.join('/usr/local', dir)
  end
  module_function :usr_dir

  # usr_ls lists matching files for /usr/<dest>/<glob>
  def usr_ls(glob, dir = 'bin')
    Dir.glob(File.join(usr_dir(dir), glob))
  end
  module_function :usr_ls

  # usr_cp copies source to /usr/<dest>/<source>
  def usr_cp(src, dest = 'bin')
    target = File.join(usr_dir(dest), File.basename(src))
    if File.exist?(target)
      warn "#{target} already exists"
    else
      sudo_cp(src, target)
    end
  end
  module_function :usr_cp

  # usr_rm removes target file from /usr/<dir>/<target>/
  def usr_rm(target, dir = 'bin')
    targetPath = File.join(usr_dir(dir), target)
    sudo_rm(targetPath)
  end
  module_function :usr_rm

  def usr_bin
    usr_dir('bin')
  end
  module_function :usr_bin

  def usr_bin_cmd(cmd)
    return File.join(usr_bin, cmd)
  end
  module_function :usr_bin_cmd

  def usr_bin_exists?(cmd)
    target = usr_bin_cmd(cmd)
    File.exist?(target)
  end
  module_function :usr_bin_exists?

  def usr_bin_cp(src, dest = nil)
    target = usr_bin_cmd(dest.nil? ? File.basename(src) : dest)
    if File.exist?(target)
      warn "#{target} already exists"
    else
      sudo_cp(src, target)
    end
  end
  module_function :usr_bin_cp

  def usr_bin_rm(cmd)
    cmd_file = usr_bin_cmd(cmd)
    sudo_rm(cmd_file)
  end
  module_function :usr_bin_rm

  def usr_bin_ln(src, target)
    src_file = File.expand_path(src)
    target_file = usr_bin_cmd(target)
    if File.exist?(target_file)
      warn "#{target} already exists"
    else
      sudo_ln(src_file, target_file)
    end
  end
  module_function :usr_bin_ln

  def usr_man_cp(src, dest = nil)
    dest_filename = dest.nil? ? File.basename(src) : dest
    target = File.join(usr_dir('share/man'),
                       "man#{File.extname(dest_filename).split('.')[1]}",
                       dest_filename)
    if File.exist?(target)
      warn "#{target} already exists"
    else
      sudo_cp(src, target)
    end
  end
  module_function :usr_man_cp

  def usr_man_rm(page)
    page_file = File.join(usr_dir('share/man'), page)
    sudo_rm(page_file)
  end
  module_function :usr_man_rm

  # Digest
  def sha1(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA1.hexdigest(contents)
    end
  end
  module_function :sha1

  def sha256(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA256.hexdigest(contents)
    end
  end
  module_function :sha256

  # GPG
  def gpg_sig(target, sig)
    `gpg --verify #{sig} #{target}`\
  end
  module_function :gpg_sig
end
