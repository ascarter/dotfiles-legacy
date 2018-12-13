# File and path helpers

require 'erb'
require 'etc'
require 'fileutils'
require 'io/console'
require 'net/http'
require 'open-uri'
require 'open3'
require 'pathname'
require 'rake'
require 'tempfile'
require 'tmpdir'
require 'uri'

# Bootstrap contains the support system for the dotfiles system
module Bootstrap
  module_function

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

  # Helpers

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

  def about(title, description='', homepage='')
    puts "#{title}"
    puts "#{description}"
    puts "#{homepage}"
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

  def home_dir
    File.expand_path(ENV['HOME'])
  end

  def config_dir
    File.expand_path(File.join(home_dir, '.config'))
  end

  def library_dir
    File.expand_path(File.join(home_dir, 'Library'))
  end

  def ssh_dir
    File.expand_path(File.join(home_dir, '.ssh'))
  end

  def projects_dir
    File.join(Bootstrap.home_dir, 'Projects')
  end

  def current_user
    Etc.getlogin
  end

  def user_info(user = Etc.getlogin)
    Etc.getpwnam(user)
  end

  def link_file(source, target)
    if File.exist?(target)
      puts "Symlink #{target} exists"
    else
      puts "Symlink #{source}"
      File.symlink(source, target)
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

  def font_dir
    case RUBY_PLATFORM
    when /darwin/
      return File.join(library_dir, 'Fonts')
    end
  end

  # dir_empty? returns if directory only contains `.` and `..`
  def dir_empty?(target)
    Dir.entries(target).size <= 2
  end

  # dir_prune removes any empty subdirectories including the target if everything is empty
  def dir_prune(target)
    return unless File.directory?(target)

    # Remove all empty subdirectories
    (Dir.entries(target) - [".", ".."]).each do |f|
      t = File.join(target, f)
      puts "checking #{t}"
      dir_prune(t) if Dir.exist?(t)
    end

    # Remove target if it is now empty
    sudo_rmdir(target) if dir_empty?(target)
  end

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

  # usr tools

  # usr_dir returns directory for /usr/<dir>
  def usr_dir(dir = 'bin')
    File.join('/usr/local', dir)
  end

  def usr_bin_cmd(cmd)
    return File.join(usr_dir('bin'), cmd)
  end

  def usr_bin_exists?(cmd)
    target = usr_bin_cmd(cmd)
    File.exist?(target)
  end

  def usr_bin_cp(src, dest = nil)
    target = usr_bin_cmd(dest.nil? ? File.basename(src) : dest)
    if File.exist?(target)
      warn "#{target} already exists"
    else
      sudo_cp(src, target)
    end
  end

  def usr_bin_rm(cmd)
    cmd_file = usr_bin_cmd(cmd)
    sudo_rm(cmd_file)
  end

  def usr_bin_ln(src, target)
    src_file = File.expand_path(src)
    target_file = usr_bin_cmd(target)
    if File.exist?(target_file)
      warn "#{target} already exists"
    else
      sudo_ln(src_file, target_file)
    end
  end

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

  def usr_man_rm(page)
    page_file = File.join(usr_dir('share/man'), page)
    sudo_rm(page_file)
  end
end
