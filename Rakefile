#  -*- mode: ruby; -*-

require 'rake'
require 'rake/clean'
require 'pathname'
require_relative 'lib/dotfiles'

# HARDCODE FOR TESTING!!
ENV['DOTFILES_VOLUME'] = File.join(home_dir, 'dtest', 'volume')

# Check for DOTFILES_VOLUME to override (useful for testing)
VOLUME_ROOT = ENV['DOTFILES_VOLUME'] || '/'
HOME_ROOT = ENV['DOTFILES_VOLUME'] ? File.join(VOLUME_ROOT, 'home') : home_dir
USR_LOCAL_ROOT = File.join(VOLUME_ROOT, 'usr', 'local')
HOMEBREW_PREFIX = File.join(VOLUME_ROOT, 'opt', 'homebrew')
SOURCE_PATHMAP_SPEC = "%{^src/,#{HOME_ROOT}/}p"

task :env do
  puts "VOLUME_ROOT=#{VOLUME_ROOT}"
  puts "HOME_ROOT=#{HOME_ROOT}"
  puts "USR_LOCAL_ROOT=#{USR_LOCAL_ROOT}"
  puts "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}"
end

SOURCES = FileList.new do |fl|
  fl.include(`git ls-files src`.lines.map { |f| f.chomp })
end

TARGETS = SOURCES.pathmap(SOURCE_PATHMAP_SPEC)

# CLEAN = FileList[]
CLOBBER.include TARGETS

task :nuke do
  if ENV['DOTFILES_VOLUME']
    sudo "rm -Rf #{VOLUME_ROOT}"
  end
end

# Base tasks that are overriden per platform
task :osinstall
task :base_packages

task :default => [ :install ]

desc 'Install configuration'
task :install => [
    VOLUME_ROOT,
    USR_LOCAL_ROOT,
    :link_sources,
    :osinstall,
    'git:config',
    'git:ignore',
    :base_packages
  ]

task :link_sources => TARGETS

directory VOLUME_ROOT

directory USR_LOCAL_ROOT do
  %w(bin lib share/man).each { |d| sh "sudo mkdir -p #{File.join(USR_LOCAL_ROOT, d)}" }
end

# Symlinks for config files in src
SOURCES.each do |src|
  file src.pathmap(SOURCE_PATHMAP_SPEC) => [ src ] do |t|
    d = t.name.pathmap('%d')
    mkdir_p d unless Dir.exists?(d)
    symlink File.expand_path(t.source), t.name
  end
end
