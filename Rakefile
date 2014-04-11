require 'rake'
require 'erb'
require 'fileutils'
require 'open-uri'
require 'pathname'
require 'uri'
require 'tmpdir'

task :default => [ :install ]
task :install => [ :bootstrap, :chsh, "rbenv:install", "virtualenv:install", "homebrew:install" ]

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

  # Set git commit editor
  atom = File.expand_path('/usr/local/bin/atom')
  if File.exist?(atom)
    sh "git config --global core.editor \"atom --wait\""
  end

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
        if File.identical?(source, target)
          puts "Identical #{file}"
        else
          puts "Diff:"
          sh "diff #{file} #{target}"
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

  # Create override directories for local changes
  ['zsh_local', 'zsh_local/functions', 'bash_local'].each do |localdir|
    target = File.expand_path(File.join(home, ".#{localdir}"))
    unless File.exist?(target)
      mkdir(target)
    else
      puts "#{localdir} exists"
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
      path_helper('homebrew', ['/opt/homebrew/bin'])
      path_helper('homebrew', ['/opt/homebrew/share/man'], 'manpaths')
      sudo "/opt/homebrew/bin/brew update"
      zsh_completion_source = File.join(homebrew_root, 'Library/Contributions/brew_zsh_completion.zsh')
      zsh_local = File.expand_path(File.join(ENV['HOME'], '.zsh_local/functions'))
      zsh_completion_target = File.expand_path(File.join(zsh_local, '_brew'))
      if File.exist?(zsh_completion_source) and File.exist?(zsh_local)
        link_file(zsh_completion_source, zsh_completion_target)
      end
    else
      puts "Homebrew not supported on #{RUBY_PLATFORM}"
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
    if RUBY_PLATFORM =~ /darwin/
      puts "Installing macports..."
      macports_root = '/opt/local'
      macports_url = 'https://distfiles.macports.org/MacPorts'
      macports_pkg = 'MacPorts-2.2.0-10.8-MountainLion.pkg'
      unless File.exist?(macports_root)
        sh "curl -L #{macports_url}/#{macports_pkg} -o /tmp/#{macports_pkg}"
        sudo "installer -pkg /tmp/#{macports_pkg} -target /"
        file_remove("/tmp/{macports_pkg}")
      end
      path_helper('macports', ['/opt/local/bin', '/opt/local/sbin'])
      path_helper('macports', ['/opt/local/share/man'], 'manpaths')
      sudo "/opt/local/bin/port -v selfupdate"
    else
      puts "Macports not supported on #{RUBY_PLATFORM}"
    end
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

  desc "Add svn source"
  task :svn_source do
    macports_root = '/opt/local'
    macports_svn_root = "#{macports_root}/sources/svn.macports.org/trunk/dports"
    macports_svn_url = 'http://svn.macports.org/repository/macports/trunk/dports/'
    sudo "mkdir -p #{macports_svn_root}"
    sudo "cd #{macports_svn_root} && svn co #{macports_svn_url} ."
    sudo "echo 'file:///opt/local/var/macports/sources/svn.macports.org/trunk/dports/' > #{macports_root}/etc/macports/sources.conf"
    sudo "port -d sync"
  end
end

namespace "rbenv" do
  desc "Install rbenv"
  task :install do
    puts "Installing rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.rbenv')))
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

  desc "Uninstall rbenv"
  task :uninstall do
    puts "Uninstalling rbenv..."
    rbenv_root = Pathname.new(File.expand_path(File.join(ENV['HOME'], '.rbenv')))
    file_remove(rbenv_root)
  end
end

namespace "sublime" do
  desc "Install sublime"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      subl_root = File.expand_path("/Applications/Sublime Text.app/Contents/SharedSupport")
    end
    if File.exist?(subl_root)
      # Symlink sublime programs
      subl_path = File.join(subl_root, 'bin', 'subl')
      usr_bin = '/usr/local/bin'
      if File.exist?(subl_path)
        ln_path = File.join(usr_bin, 'subl')
        sudo "ln -s \"#{subl_path}\" \"#{ln_path}\"" unless File.exist?(ln_path)
      end
    end
  end

  desc "Uninstall sublime"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      subl_path = '/usr/local/bin/subl'
    end
    if File.exist?(subl_path)
      sudo_remove(subl_path)
    end

  end
end

namespace "virtualenv" do
  desc "Install virtualenv"
  task :install do
    virtualenv_root = File.expand_path("~/.virtualenvs")

    unless File.exist?('/usr/local/bin/pip')
      puts "Install pip..."
      sudo "easy_install --upgrade pip"
    end

    pip_install("virtualenv", true)
    pip_install("virtualenvwrapper", true)

    unless File.exist?(virtualenv_root)
      puts "Creating #{virtualenv_root}"
      Dir.mkdir(virtualenv_root)
    end
  end

  desc "Uninstall virtualenv"
  task :uninstall do
    pip_uninstall("virtualenv", true)
    pip_uninstall("virtualenvwrapper", true)
  end
end

namespace "atom" do
  desc "Install atom support"
  task :install do

  end

  task :uninstall do

  end
end

namespace "vim" do
  desc "Install vim support"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      #Install MacVim      
      unless File.exist?('/Applications/MacVim.app')
        snapshot = 'snapshot-72'
        snapshot_pkg = "MacVim-#{snapshot}-Mavericks.tbz"
        snapshot_url = "https://github.com/b4winckler/macvim/releases/download/#{snapshot}/#{snapshot_pkg}"
        snapshot_pkg_path = File.join('/tmp', snapshot_pkg)
        snapshot_src = File.join('/tmp', "MacVim-#{snapshot}")
        puts "Downlaoding #{snapshot_url}..."
        download_file(snapshot_url, snapshot_pkg_path)
        cmd = "cd /tmp && tar xvzf #{snapshot_pkg}"
        sh cmd
        cmd = "mv #{snapshot_src}/MacVim.app /Applications/. && mv #{snapshot_src}/mvim /usr/local/bin/."
        sudo cmd
        file_remove(File.join('/tmp', "MacVim-#{snapshot}"))
        file_remove(snapshot_pkg_path)
      else
        puts "MacVim already installed"
      end

      # Symlink vim programs to mvim on mac
      usr_bin = '/usr/local/bin'
      mvim_path = File.join(usr_bin, 'mvim')
      if File.exist?(mvim_path)
        # Gui, Diff, Read-only, Ex, Restricted
        %w(gvim mvimdiff mview mex rmvim vim).each do |prog|
          ln_path = File.join(usr_bin, prog)
          sudo "ln -s #{mvim_path} #{ln_path}" unless File.exist?(ln_path)
        end
      end
    end

    # Vundle install
    vundle_path = File.expand_path(File.join(ENV['HOME'], '.vim/bundle/vundle'))
    unless File.exist?(vundle_path)
      git_clone('gmarik', 'vundle', vundle_path)
      sh "vim +PluginInstall +qall"
    else
      puts "Update vundle"
      git_pull(vundle_path)
      sh "vim +PluginInstall +qall"
    end
  end

  desc "Uninstall vim support"
  task :uninstall do
    usr_bin = '/usr/local/bin'
    mvim_path = File.join(usr_bin, 'mvim')
    if File.exist?(mvim_path)
      # Gui, Diff, Read-only, Ex, Restricted
      %w(gvim mvimdiff mview mex rmvim vim).each do |prog|
        target = File.expand_path(File.join(usr_bin, prog))
        sudo_remove(target)
      end
    end

    bundle_path = File.expand_path(File.join(ENV['HOME'], '.vim/bundle'))
    if File.exist?(bundle_path)
      file_remove(bundle_path)
    end

    macvim_path = '/Applications/MacVim.app'
    if File.exist?(macvim_path)
      sudo_remove(macvim_path)
    end
  end
end

namespace "cinnamon" do
  desc "Install for Ubuntu"
  task :install do
    sudo "sudo add-apt-repository ppa:gwendal-lebihan-dev/cinnamon-stable"
    sudo "apt-get update"
    sudo "apt-get install cinnamon"
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
