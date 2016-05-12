#  -*- mode: ruby; -*-

require 'rake'

require_relative 'lib/bootstrap'

task :default => [ :install ]

desc "Install default configuration"
task :install => [ :bootstrap, "git:config", "rbenv:install", "vim:install" ]

desc "Change default shell"
task :chsh do
  puts "Setting shell to bash"
  system "chsh -s /bin/bash"
end

desc "Bootstrap dotfiles to home directory using symlinks"
task :bootstrap do
  replace_all = false
  srcdir = File.expand_path('src')
  Dir.new(srcdir).each do |file|
    unless %w(. ..).include?(file)
      source = File.join(srcdir, file)
      target = File.expand_path(File.join(Bootstrap.home_dir(), ".#{file}"))
      if File.exist?(target) or File.symlink?(target) or File.directory?(target)
        if File.identical?(source, target)
          puts "Identical #{file}"
        else
          puts "Diff:"
          system "diff #{source} #{target}"
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
  src = File.expand_path('src')
  Dir.new(src).each do |file|
    unless %w(. ..).include?(file)
      target = File.join(home_dir(), ".#{file}")
      file_remove(target)
    end
  end
end

# Mac tasks

if RUBY_PLATFORM =~ /darwin/
  desc "Install Mac development environment"
  task :macdev => [ :install, "homebrew:install", "bbedit:install", "github:install" ]
end

# Linux tasks

if RUBY_PLATFORM =~ /linux/
  desc "Install Linux development environment"
  task :linuxdev => [ :install, "github:install" ]
end

# Windows tasks

desc "Install Windows development environment"
task :windev => [ :install, "github:install" ]
