#  -*- mode: ruby; -*-

require 'rake'

require_relative 'lib/bootstrap'

task :default => [ :install ]

desc 'Install default configuration'
task :install => [ :bootstrap, :configenv, 'git:config', 'rbenv:install', 'vim:install' ]

desc 'Change default shell'
task :chsh do
  puts 'Setting shell to bash'
  system 'chsh -s /bin/bash'
end

desc 'Bootstrap dotfiles to home directory using symlinks'
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
          puts 'Diff:'
          system "diff #{source} #{target}"
          if replace_all
            Bootstrap.replace(source, target)
          else
            print "Replace existing file #{file}? [ynaq] "
            case $stdin.gets.chomp
            when 'a'
              replace_all = true
              Bootstrap.replace(source, target)
            when 'y'
              Bootstrap.replace(source, target)
            when 'q'
              warn 'Abort'
              exit
            else
              puts "Skipping #{file}"
            end
          end
        end
      else
        Bootstrap.link_file(source, target)
      end
    end
  end
end

desc 'Configure environment'
task :configenv do
  case RUBY_PLATFORM
  when /darwin/
    Bootstrap::MacOSX.build_locatedb
  end
end

desc 'Uninstall dotfiles from home directory'
task :uninstall do
  src = File.expand_path('src')
  Dir.new(src).each do |file|
    unless %w(. ..).include?(file)
      target = File.join(home_dir(), ".#{file}")
      file_remove(target)
    end
  end
end

# Work configuration
desc 'Work development configuration'
task :workdev => [ :macdev, 'hipchat:install', 'zoom:install', 'viscosity:install' ]

case RUBY_PLATFORM
when /darwin/
  desc 'Install Mac development environment'
  task :macdev => [
    :install,
    'android:install',
    'bbedit:install',
    'coderunner:install',
    'colorpicker:install',
    'github:install',
    'golang:install',
    'homebrew:install',
    'icloud:install',
    'intellij:install',
    'mysql:sequelpro:install',
    'postgres:install',
    'safari:install',
    'xquartz:install',
  ]
when /linux/
  desc 'Install Linux development environment'
  task :linuxdev => [
    :install,
    'android:install',
    'github:install',
    'intellij:install',
    'mysql:sequelpro:install',
    'postgres:install',
  ]
when /windows/
  desc 'Install Windows development environment'
  task :windev => [
    :install,
    'android:install',
    'github:install',
    'intellij:install',
    'mysql:sequelpro:install',
    'postgres:install',
  ]
end
