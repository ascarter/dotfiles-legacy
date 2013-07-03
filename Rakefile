require 'rake'
require 'erb'
require 'uri'
require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open-uri'

task :default => [ :install ]
task :install => [ :bootstrap, :chsh, "packages:rbenv", "packages:homebrew", "packages:virtualenv" ]

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
      if File.exist?(target) or File.symlink?(target) or File.directory?(target)
        puts "Removing #{target}"
        File.delete(target)
      end
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

	desc "Install homebrew"
	task :homebrew do
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

	desc "Install vim support"
	task :vim do
    vim_root = File.join(File.dir(__FILE__), 'vim')
	end
	
	desc "Install terminal-notifier"
	task :terminal_notifer do
	  zipfile = "https://github.com/downloads/alloy/terminal-notifier/terminal-notifier_1.4.2.zip"
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

