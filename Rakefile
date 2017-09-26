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

desc 'Create /usr/local directory'
task :usrlocal do
	Bootstrap.sudo_mkdir('/usr/local')
end

desc 'Bootstrap dotfiles to home directory using symlinks'
task :bootstrap => [ :usrlocal ] do
  Bootstrap.bootstrap(File.expand_path('home'), Bootstrap.home_dir())
  Bootstrap.bootstrap(File.expand_path('config'), Bootstrap.config_dir())
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
  Bootstrap.unbootstrap(File.expand_path('home'), Bootstrap.home_dir())
  Bootstrap.unbootstrap(File.expand_path('config'), Bootstrap.config_dir())
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
    'icloud:install',
    'gpg:install',
    '1password:install',
    'keybase:install',
    'homebrew:install',
    'bbedit:install',
    'github:install',
    'coderunner:install',
    'golang:install',
    'paw:install',
    'postgres:install',
    'mysql:sequelpro:install',
    'xquartz:install',
    'jetbrains:install',
    'android:install',
    # 'sketch:install',
    'sanfrancisco:install',
  ]
when /linux/
  desc 'Install Linux development environment'
  task :linuxdev => [
    :install,
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
