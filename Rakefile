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
task :install => [ :bootstrap, :chsh, "git:config", "rbenv:install", "virtualenv:install", "homebrew:install", "vim:install" ]

desc "Change default shell"
task :chsh do
  puts "Setting shell to zsh"
  sh "chsh -s /bin/zsh"
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
