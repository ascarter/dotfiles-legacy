#  -*- mode: ruby; -*-

require 'rake'

task :default => [ :install ]

desc 'Install default configuration'
task :install => [ :bootstrap, :configenv, 'git:config' ]

desc 'Change default shell'
task :chsh do
  puts 'Setting shell to bash'
  system 'chsh -s /bin/bash'
end

desc 'Bootstrap dotfiles to home directory using symlinks'
task :bootstrap => [ :usrlocal ] do
  Bootstrap.bootstrap('home', Bootstrap.home_dir())
  Bootstrap.bootstrap('config', Bootstrap.config_dir())
  Bootstrap.bootstrap('Library', Bootstrap.library_dir(), true)
end

desc 'Uninstall dotfiles from home directory'
task :uninstall do
  Bootstrap.unbootstrap('home', Bootstrap.home_dir())
  Bootstrap.unbootstrap('config', Bootstrap.config_dir())
  Bootstrap.unbootstrap('Library', Bootstrap.library_dir(), true)
end

case RUBY_PLATFORM
when /darwin/
  desc 'Install Mac development environment'
  task :macdev => [
    :install,
    'icloud:install',
    'homebrew:install'
  ]
when /linux/
  desc 'Install Linux development environment'
  task :linuxdev => [
    :install
  ]
when /windows/
  desc 'Install Windows development environment'
  task :windev => [
    :install
  ]
end

# Work configuration
desc 'Work development configuration'
task :workdev => [
  :macdev
]

task :usrlocal do
  %w(bin lib share/man).each { |d| Bootstrap.sudo_mkdir(File.join('/usr/local', d)) }
end

task :configenv do
  case RUBY_PLATFORM
  when /darwin/
    MacOS.build_locatedb
  end
end

