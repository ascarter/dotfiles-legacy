#  -*- mode: ruby; -*-

require 'rake'
require 'erb'
require 'fileutils'
require 'open-uri'
require 'pathname'
require 'uri'
require 'tmpdir'

require_relative 'rakelib/utils.rb'

task :default => [ :install ]

desc "Install default configuration"
task :install => [ :bootstrap, :chsh, "git:config", "rbenv:install", "homebrew:install", "vim:install" ]

desc "Change default shell"
task :chsh do
  puts "Setting shell to zsh"
  sh "chsh -s /bin/zsh"
end

desc "Bootstrap dotfiles to home directory using symlinks"
task :bootstrap do
  replace_all = false
  srcdir = File.expand_path('src')
  Dir.new(srcdir).each do |file|
    unless %w(. ..).include?(file)
      source = File.join(srcdir, file)
      target = File.expand_path(File.join(home_dir(), ".#{file}"))
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
    target = File.join(home_dir(), ".#{localdir}")
    unless File.exist?(target)
      mkdir(target)
    else
      puts "#{localdir} exists"
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
