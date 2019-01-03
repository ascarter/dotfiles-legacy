#  -*- mode: ruby; -*-

require 'rake'
require 'rake/clean'
require 'pathname'

require_relative 'lib/dotfiles'

# Uncomment to HARDCODE FOR TESTING!!
# ENV['DOTFILES_VOLUME'] = File.join(home_dir, 'dtest', 'volume')

# Check for DOTFILES_VOLUME override (useful for testing)
VOLUME_ROOT = ENV['DOTFILES_VOLUME'] || '/'
HOME_ROOT = ENV['DOTFILES_VOLUME'] ? File.join(VOLUME_ROOT, 'home') : home_dir
USR_LOCAL_ROOT = File.join(VOLUME_ROOT, 'usr', 'local')
USR_LOCAL_SUBDIRS = %w(bin lib share/man).map { |d| File.join(USR_LOCAL_ROOT, d) }
SOURCE_PATHMAP_SPEC = "%{^src/,#{HOME_ROOT}/}p"

task :env do
  puts "VOLUME_ROOT=#{VOLUME_ROOT}"
  puts "HOME_ROOT=#{HOME_ROOT}"
  puts "USR_LOCAL_ROOT=#{USR_LOCAL_ROOT}"
end

SOURCES = FileList.new do |fl|
  fl.include(`git ls-files src`.lines.map { |f| f.chomp })
end
TARGETS = SOURCES.pathmap(SOURCE_PATHMAP_SPEC)

CLOBBER.include TARGETS

task :nuke => [ :env ] do
  if ENV['DOTFILES_VOLUME']
    raise "Root volume '/' set!" if VOLUME_ROOT == '/'
    confirm = prompt("Confirm remove volume root #{VOLUME_ROOT}? (Y/N)", "N")
    raise "Cancel nuke" if confirm.upcase != 'Y'
    sudo "rm -Rf #{VOLUME_ROOT}"
  end
end

# Base tasks that are overriden per platform
task :osinstall
task :base_packages

task :default => [ :install ]

desc 'Install dotfiles'
task :install => [
    VOLUME_ROOT,
    :usr_local,
    :link_sources,
    :osinstall,
    'git:config',
    'ssh:config',
    :base_packages
  ]

desc 'Uninstall dotfiles'
task :uninstall => [ 'homebrew:uninstall', :clobber ]

directory VOLUME_ROOT

task :usr_local => [ USR_LOCAL_ROOT ] + USR_LOCAL_SUBDIRS

file USR_LOCAL_ROOT do |t|
  sudo "mkdir -p #{USR_LOCAL_ROOT}"
end

USR_LOCAL_SUBDIRS.each do |d|
  file d do |t|
    sudo %(mkdir -p "#{t.name}")
  end
end

# Generate tasks to create symlinks for config files in src
SOURCES.each do |src|
  file src.pathmap(SOURCE_PATHMAP_SPEC) => [ src ] do |t|
    d = t.name.pathmap('%d')
    mkdir_p d unless Dir.exists?(d)
    symlink File.expand_path(t.source), t.name
  end
end

task :link_sources => TARGETS
