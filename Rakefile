#  -*- mode: ruby; -*-

require 'rake'

require_relative 'lib/bootstrap'

task :default => [ :install ]

desc 'Install default configuration'
task :install => [ :bootstrap, :configenv, 'git:config' ]

desc 'Change default shell'
task :chsh do
  puts 'Setting shell to bash'
  system 'chsh -s /bin/bash'
end

desc 'Create /usr/local directory'
task :usrlocal do
	Bootstrap.sudo_mkdir('/usr/local')
end

desc 'Bootstrap dotfiles to home directory using symlinks'
task :bootstrap => [ :usrlocal ] do
  Bootstrap.bootstrap('home', Bootstrap.home_dir())
  Bootstrap.bootstrap('config', Bootstrap.config_dir())
  Bootstrap.bootstrap('Library', Bootstrap.library_dir(), true)
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
  Bootstrap.unbootstrap('home', Bootstrap.home_dir())
  Bootstrap.unbootstrap('config', Bootstrap.config_dir())
  Bootstrap.unbootstrap('Library', Bootstrap.library_dir(), true)
end

# Work configuration
desc 'Work development configuration'
task :workdev => [
  :macdev,
  'nvm:install',
  'zoom:install',
  'viscosity:install'
]

case RUBY_PLATFORM
when /darwin/
  desc 'Install Mac development environment'
  task :macdev => [
    :install,
    'rbenv:install',
    'icloud:install',
    'gpg:install',
    '1password:install',
    'keybase:install',
    'homebrew:install',
    'bbedit:install',
    'github:install',
    'dash:install',
    'coderunner:install',
    'golang:install',
    'paw:install',
    'postgres:install',
    'mysql:sequelpro:install',
    'xquartz:install',
    'jetbrains:install',
    'android:install',
    'sanfrancisco:install',
  ]
when /linux/
  desc 'Install Linux development environment'
  task :linuxdev => [
    :install,
    'rbenv:install',
    'gpg:install',
    'android:install',
    'github:install',
    'jetbrains:install',
    'mysql:sequelpro:install',
    'postgres:install',
  ]
when /windows/
  desc 'Install Windows development environment'
  task :windev => [
    :install,
    'gpg:install',
    'android:install',
    'github:install',
    'jetbrains:install',
    'mysql:sequelpro:install',
    'postgres:install',
  ]
end
