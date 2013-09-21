require 'rake'
require 'erb'
require 'uri'
require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open-uri'

task :default => [ :install ]
task :install => [ :bootstrap, :chsh, "packages:rbenv", "packages:virtualenv" ]

desc "Change default shell"
task :chsh do
  puts "Setting shell to zsh"
  sh "chsh -s /bin/zsh"
end

desc "Update git config"
task :gitconfig do
  puts "Setting git config"
  source = File.expand_path('gitconfig')
  target = File.join(File.expand_path(ENV['HOME']), '.gitconfig')
  copy_and_replace(source, target)
  name = prompt("user name")
  email = prompt("user email")
  sh "git config --global user.name \"#{name}\""
  sh "git config --global user.email \"#{email}\""
  
  # Configure password caching
  if RUBY_PLATFORM =~ /darwin/
    sh "git config --global credential.helper osxkeychain"
    sh "git config --global merge.tool Kaleidoscope"
    sh "git config --global diff.tool Kaleidoscope"
    sh "git config --global gui.fontui '-family \"Lucida Grande\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0'"
  sh "git config --global gui.fontdiff '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0'"
  elsif RUBY_PLATFORM =~ /linux/
    sh "git config --global credential.helper cache"
    # sh "git config --global merge.tool Kaleidoscope"
    sh "git config --global diff.tool meld"
    sh "git config --global gui.fontui '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0'"
  sh "git config --global gui.fontdiff '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'"
  end
end

desc "Bootstrap dotfiles to home directory using symlinks"
task :bootstrap do
  replace_all = false
  home = File.expand_path(ENV['HOME'])
  srcdir = File.expand_path('src')
  Dir.new(srcdir).each do |file|
    unless %w(. ..).include?(file)
      source = File.join(srcdir, file)
      target = File.expand_path(File.join(home, ".#{file}"))
      if File.exist?(target) or File.symlink?(target) or File.directory?(target)
        if File.identical?(file, target)
          puts "Identical #{filename}"
        else
          if replace_all
            replace(source, target)
          else
            print "Replace existing file #{file}? [ynaq] "
            case $stdin.gets.chomp
            when 'a'
              replace_all = true
              replace(source, target)
            when 'y'
              replace(source, target)
            when 'q'
              puts "Abort"
              exit
            else
              puts "Skipping #{file}"
            end
          end
        end
      else
        link_file(source, target)
      end
    end
  end
end

desc "Uninstall dotfiles from home directory"
task :uninstall do
  home = File.expand_path(ENV['HOME'])
  src = File.expand_path('src')
  Dir.new(src).each do |file|
    unless %w(. ..).include?(file)
      target = File.expand_path(File.join(home, ".#{file}"))
      file_remove(target)
    end
  end
end

namespace "fonts" do
  task :default => [ :all ]

  desc "Install all fonts"
  task :all => [ :sourcecodepro ]
  
  desc "Adobe SourceCodePro"
  task :sourcecodepro do
#     install_font('SourceCodePro', 'http://sourceforge.net/projects/sourcecodepro.adobe/files/latest/download')
#   #!/bin/bash
#   FONT_NAME="SourceCodePro"
#   URL="http://sourceforge.net/projects/sourcecodepro.adobe/files/latest/download"
# 
#   mkdir /tmp/adodefont
#   cd /tmp/adodefont
#   wget ${URL} -O ${FONT_NAME}.zip
#   unzip -o -j ${FONT_NAME}.zip
#   mkdir -p ~/.fonts
#   cp *.otf ~/.fonts
#   fc-cache -f -v
# 
  end
end

namespace "packages" do
  desc "Install/update rbenv"
  task :rbenv do
    puts "Installing rbenv..."
    rbenv_root = Pathname.new(File.expand_path("~/.rbenv"))
    plugins = %w{ruby-build rbenv-vars rbenv-gem-rehash rbenv-default-gems}
    
    unless File.exist?(rbenv_root.to_s)
      git_clone('sstephenson', 'rbenv', rbenv_root)
      plugins.each do |plugin|
        git_clone('sstephenson', plugin, rbenv_root.join('plugins', plugin))
      end
    else
      puts "Updating rbenv..."
      system "cd #{rbenv_root} && git pull"
      plugins.each do |plugin|
        puts "Updating #{plugin}..."
        system "cd #{rbenv_root}/plugins/#{plugin} && git pull"
      end
    end
  end

  desc "Install pip/virtualenv"
  task :virtualenv do
    virtualenv_root = File.expand_path("~/.virtualenvs")
    
    # macosx - backup easy_install-2.7 because it gets broken during virtualenv install
    if RUBY_PLATFORM =~ /darwin/
      puts "Backing up easy_install-2.7..."
      FileUtils.copy("/usr/bin/easy_install-2.7", "/tmp/easy_install-2.7")
      sudo "cp /usr/bin/easy_install-2.7 /tmp/."
    end
    
    puts "Install pip..."
    sudo "easy_install --upgrade pip"
    pip_install("virtualenv", true)
    pip_install("virtualenvwrapper", true)
    unless File.exist?(virtualenv_root)
      puts "Creating #{virtualenv_root}"
      Dir.mkdir(virtualenv_root)
    end
    
    # macosx - restore original easy_install-2.7 script
    if RUBY_PLATFORM =~ /darwin/
      puts "Restore easy_install-2.7..."
      sudo "cp /tmp/easy_install-2.7 /usr/bin/."
    end   
  end
  
  desc "Install terminal-notifier"
  task :terminal_notifer do
    zipfile = "https://github.com/downloads/alloy/terminal-notifier/terminal-notifier_1.4.2.zip"
  end
end

namespace "homebrew" do
  desc "Install homebrew"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      puts "Installing homebrew..."
      homebrew_root = '/opt/homebrew'
      unless File.exist?(homebrew_root)
        sudo "mkdir -p #{homebrew_root}"
        sudo "curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C #{homebrew_root}"
      end
      sudo "echo '/opt/homebrew/bin' > /etc/paths.d/homebrew"
      sudo "echo '/opt/homebrew/share/man' > /etc/manpaths.d/homebrew"
      sudo "/opt/homebrew/bin/brew update"
    end
  end
  
  desc "Uninstall homebrew"
  task :uninstall do
    homebrew_root = '/opt/homebrew'
    #if File.exist?(homebrew_root)
      installed_files = [
        '~/Library/Caches/Homebrew',
        '~/Library/Logs/Homebrew',
        '/Library/Caches/Homebrew',
        '/etc/paths.d/homebrew',
        '/etc/manpaths.d/homebrew'
      ]
      sudo "rm -rf #{homebrew_root}"
      sudo "rm -rf #{installed_files.join(' ')}"
    #end
  end
end

namespace "macports" do
  desc "Install macports"
  task :install do
    puts "Installing macports..."
    macports_root = '/opt/local'
    macports_url = 'https://distfiles.macports.org/MacPorts'
    macports_pkg = 'MacPorts-2.2.0-10.8-MountainLion.pkg'
    unless File.exist?(macports_root)
      sh "curl -L #{macports_url}/#{macports_pkg} -o /tmp/#{macports_pkg}"
      sudo "installer -pkg /tmp/#{macports_pkg} -target /"
      file_remove("/tmp/{macports_pkg}")
    end
    sudo "echo '/opt/local/bin' > /etc/paths.d/macports"
    sudo "echo '/opt/local/sbin' >> /etc/paths.d/macports"
    sudo "echo '/opt/local/share/man' > /etc/manpaths.d/macports"
    sudo "/opt/local/bin/port -v selfupdate"
  end
  
  desc "Uninstall macports"
  task :uninstall do
    puts "Uninstall macports..."
    macports_root = '/opt/local'
    installed_files = [
      '/opt/local',
      '/Applications/DarwinPorts',
      '/Applications/MacPorts',
      '/Library/LaunchDaemons/org.macports.*',
      '/Library/Receipts/DarwinPorts*.pkg',
      '/Library/Receipts/MacPorts*.pkg',
      '/Library/StartupItems/DarwinPortsStartup',
      '/Library/Tcl/darwinports1.0',
      '/Library/Tcl/macports1.0',
      '~/.macports',
      '/etc/paths.d/macports',
      '/etc/manpaths.d/macports'
    ]
    sudo "port -fp uninstall installed"
    sudo "rm -rf #{installed_files.join(' ')}"
  end
end
namespace "vim" do
  desc "Install vim support"
  task :install do
    # Symlink vim programs to mvim on mac
    usr_bin = '/usr/local/bin'
    mvim_path = File.join(usr_bin, 'mvim')
    if File.exist?(mvim_path)
      # Gui, Diff, Read-only, Ex, Restricted
      %w(gvim mvimdiff mview mex rmvim).each do |prog|
        sudo "ln -s #{mvim_path} #{File.join(usr_bin, prog)}"
      end
    end
  end
  
  desc "Uninstall vim support"
  task :uninstall do
    usr_bin = '/usr/local/bin'
    mvim_path = File.join(usr_bin, 'mvim')
    if File.exist?(mvim_path)
      # Gui, Diff, Read-only, Ex, Restricted
      %w(gvim mvimdiff mview mex rmvim).each do |prog|
        target = File.expand_path(File.join(usr_bin, prog))
        sudo_remove(target)
      end
    end
  end
    
end

namespace "gnome" do
  namespace "terminal" do
    desc "Export terminal settings"
    task :export do
      termdir = File.join(File.expand_path('terminal'), 'gnome')
      export_file = File.join(termdir, 'gnome-terminal-conf.xml')
      system "gconftool-2 --dump '/apps/gnome-terminal' > #{export_file}"
    end

    desc "Import terminal settings"
    task :import do
      termdir = File.join(File.expand_path('terminal'), 'gnome')
      import_file = File.join(termdir, 'gnome-terminal-conf.xml')
      system "gconftool-2 --load #{import_file}"
    end
  end
end

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

