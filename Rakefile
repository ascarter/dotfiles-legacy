#  -*- mode: ruby; -*-

require 'rake'
require_relative 'lib/dotfiles'

DEST_ROOT = ENV['DEST'] || home_dir
USR_LOCAL = File.join('/usr', 'local')

SOURCE_FILES = FileList['src/*']
TARGET_FILES = SOURCE_FILES.map { |f| File.join(DEST_ROOT, f) }

task :default => [ :install ]

desc 'Install configuration'
task :install => [ USR_LOCAL  ]  #, :configenv, 'git:config', :osinstall, :base_packages ]

directory USR_LOCAL do
  %w(bin lib share/man).each { |d| sh "sudo mkdir -p #{File.join USR_LOCAL, d}" }
end

task :configenv => [ 'ssh:install' ] do
  case RUBY_PLATFORM
  when /darwin/
    MacOS.build_locatedb
  end
end

desc 'Change default shell'
task :chsh do
  puts 'Setting shell to bash'
  system 'chsh -s /bin/bash'
end

# Collections
# 
# case RUBY_PLATFORM
# when /darwin/
#   task :work do
#     taps = []
# 
#     pkgs = []
# 
#     casks = [
#       'firefox',
#       'firefox-developer-edition',
#       'google-chrome',
#       'slack',
#       'zoomus'
#     ]
# 
#     Homebrew.collection taps: taps, pkgs: pkgs, casks: casks
#   end
# when /linux/
# when /windows/
# end

# desc 'Install Homebrew'
# directory Homebrew::Root do
#   Bootstrap.sudo_mkdir Homebrew::ROOT
#   Bootstrap.sudo_chown Homebrew::ROOT
#   Bootstrap.sudo_chgrp Homebrew::ROOT
#   Bootstrap.sudo_chmod Homebrew::ROOT
#
#   bin_path = File.join(Homebrew::ROOT, 'bin')
#   MacOS.path_helper 'homebrew', [ bin_path ]
#   system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{Homebrew::ROOT}"
# end

