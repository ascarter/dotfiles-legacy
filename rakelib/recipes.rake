require 'rake'
require 'erb'
require 'pathname'
require 'yaml'

# Import rake actions and legacy tasks
Dir.glob(File.join(File.dirname(__FILE__), '*/*.rake')).each { |r| import r }

RECIPES_DIR = Pathname.new('recipes')

# Check for debug mode
DEBUG = ENV.member?('DEBUG')

desc "Generator for new recipes"
task :create do
  ns = Bootstrap.prompt("task name (namespace using ':')")
  parts = ns.split(':')
  name = parts[-1]
  target = File.join(RECIPES_DIR, parts[0..-2], name + '.yml')

  template = <<-EOB
description: About #{name}
homepage:    http://example.com/#{name}/
macos:
  app:    #{name}
  source: http://example.com/#{name}/download
EOB

  body = ERB.new(template).result(binding)
  mkdir_p File.dirname(target)
  File.open(target, 'w') { |f| f.write(body) }
  open_file target
end

class Recipe
  attr_reader :name, :config, :platform

  def initialize(src)
    p = Pathname.new(src).relative_path_from(RECIPES_DIR).to_s()
    @ns = File.basename(p.sub(File::SEPARATOR, ':'), ".*")
    @config = YAML.load_file(src)
    @name = @config['name'] || @ns.split(":")[-1]
    @platform = case RUBY_PLATFORM
      when /darwin/
        @config['macos']
      when /linux/
        @config['linux']
      when /windows/
        @config['windows']
    end
  end

  def namespace
    @ns
  end

  def description
    @config['description']
  end

  def homepage
    @config['homepage']
  end

  def source_url
    @platform['source']
  end

  def dest
    @platform['dest'] || '/usr/local'
  end

  def app
    @platform['app']
  end

  def appbundle(appname)
    File.join("/Applications", appname + ".app")
  end

  def sig
    @platform['sig'] || {}
  end

  def headers
    @platform['headers'] || {}
  end

  # config_commands returns all keys that are commands and excludes before/after
  def self.has_commands?(config)
    config.keys.any? { |k| !['before', 'after'].include? k }
  end

end

# Task helpers

# Return the best matching method for an action
# Actions are expected to be either a string for a method in the provided module
# or using syntax <submodule>_<method> for submodule matches
# If no match is found, nil is returned and nothing is run
def find_method(mod, action)
  parts = action.split('_', 2)
  case parts.length
  when 1
    # Method only
    meth = parts[0]
  when 2
    # Sub-module and method
    submod, meth = parts
    action_mod = submod + 'Actions'
    matches = mod.constants.select { |c| action_mod.casecmp(c.to_s) == 0 }
    raise "Action module #{submod} not found" unless matches.length > 0
    mod = mod.const_get(matches[0])
  end

  mod.method(meth.to_sym)
end

def default_task(recipe, task)
  desc recipe.description || recipe.name
  task "#{recipe.namespace}" => ["#{recipe.namespace}:about", "#{recipe.namespace}:#{task}"]
end

def about_task(recipe)
  namespace "#{recipe.namespace}" do
    task :about do
      puts "#{recipe.description}"
      puts "#{recipe.homepage}"
    end
  end
end

def update_task(recipe)
  namespace "#{recipe.namespace}" do
    task update: [:uninstall, :install]
  end
end

def exec_task(recipe, task)
  begin
    run_stage recipe, task, 'before'
    yield
    run_stage recipe, task, 'after'
  rescue => ex
    print ex
  end
end

def open_file(filepath)
  system %Q{${VISUAL} "#{filepath}"}
end

# run_stage finds actions for stage on task and executes.
# Actions are implemented in the `actions` folder
#
# stage:
#   nil     - look for actions on task
#   <stage> - look for actions on stage
def run_stage(recipe, task, stage=nil)
  return unless recipe.platform.has_key?(task)
  cfg = recipe.platform[task]

  if stage.nil?
    # Ignore before/after blocks
    cfg = cfg.reject { |k,v| %w(before after).include? k }
  else
    return unless cfg.has_key?(stage)
    cfg = cfg[stage]
  end

  puts "#{recipe.name}:#{task}#{":#{stage}" unless stage.nil?}" if DEBUG

  # Run actions in order
  cfg.each do |action, args|
    puts "\t#{action}" if DEBUG
    meth = find_method(Actions, action)
    if meth.nil?
      puts "\t ==> No action for #{action}" if DEBUG
      next
    end
    meth.call(args)
  end
end

def command_install_task(recipe)
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        run_stage recipe, 'install'
      end
    end
  end
end

def command_uninstall_task(recipe)
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        run_stage recipe, 'uninstall'
      end
    end
  end
end

def manifest_install_task(recipe)
  cfg = recipe.platform['install']
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        options = {
          dest:    recipe.dest,
          sig:     recipe.sig,
          headers: recipe.headers
        }
        Archive.install cfg['manifest'], recipe.source_url, options
      end
    end
  end
end

def manifest_uninstall_task(recipe)
  cfg = recipe.platform['uninstall']
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        Archive.uninstall cfg['manifest'], dest: recipe.dest
      end
    end
  end
end

# Generate tasks from recipes
FileList['recipes/**/*.yml', 'recipes/**/*.yaml'].each do |src|
  recipe = Recipe.new(src)
  case RUBY_PLATFORM
  when /darwin/
    mac_tasks(recipe) if recipe.config.include?('macos')
  when /linux/
    linux_tasks(recipe) if recipe.config.include?('linux')
  when /windows/
    windows_tasks(recipe) if recipe.config.include?('windows')
  end
end
