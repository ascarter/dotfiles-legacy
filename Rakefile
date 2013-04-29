require 'rake'
require 'erb'
require 'uri'
require 'pathname'
require 'fileutils'

task :default => [ :install ]
task :install => [ :bootstrap, :chsh, "packages:rbenv", "packages:homebrew", "packages:virtualenv" ]

desc "Change default shell"
task :chsh do
  puts "Setting shell to zsh"
  sh "chsh -s /bin/zsh"
end

desc "Bootstrap dotfiles to home directory using symlinks"
task :bootstrap do
  replace_all = false
  home = File.expand_path(ENV['HOME'])

  Dir['*'].each do |file|
    next if %w(Rakefile README.md).include?(file)
    filename = file.sub('.erb', '')
    target = File.expand_path(File.join(home, ".#{filename}"))
    if File.exist?(target) or File.symlink?(target) or File.directory?(target)
      if File.identical?(file, target)
        puts "Identical #{filename}"
      else
        if replace_all
          replace(file, target)
        else
          print "Replace existing file #{filename}? [ynaq] "
          case $stdin.gets.chomp
          when 'a'
            replace_all = true
            replace(file, target)
          when 'y'
            replace(file, target)
          when 'q'
            puts "Abort"
            exit
          else
            puts "Skipping #{filename}"
          end
        end
      end
    else
      link_file(file, target)
    end
  end
end

namespace "packages" do
	desc "Install rbenv"
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
end

def link_file(file, target)
  filename = file.sub('.erb', '')
  if file =~ /.erb$/
    puts "Generating #{filename}"
    File.open(target, 'w') do |output|
      output.write(ERB.new(File.read(file)).result(binding))
    end
  else
    puts "Symlink #{filename}"
    source = File.expand_path(File.join(File.dirname(__FILE__), file))
    File.symlink(source, target)
  end
end

def replace(file, target)
  backup = "#{target}.orig"
  puts "Backing up #{target} to #{backup}"
  File.rename(target, backup)
  link_file(file, target)
end

def prompt_for_value(message)
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