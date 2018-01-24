require 'rake'
require 'erb'
require 'pathname'
require 'yaml'

RECIPES_DIR = Pathname.new('recipes')

desc "Generator for new recipes"
task :create do
  ns = Bootstrap.prompt("task name (namespace using ':')")
  parts = ns.split(':')
  name = parts[-1]
  target = File.join(RECIPES_DIR, parts[0..-2], name + '.yml')

  template = <<-EOB
# #{name}
description: About #{name}
homepage:    http://example.com/#{name}/
macos:
    app:    #{name}
    source: http://example.com/#{name}/download
  EOB

  body = ERB.new(template).result(binding)
  mkdir_p File.dirname(target)
  File.open(target, 'w') { |f| f.write(body) }
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

  def app
    @platform['app']
  end
  
  def appbundle
    File.join("/Applications", app + ".app") if @platform.has_key?('app')
  end
    
  def sig
    @platform['sig'] || {}
  end
end

# Task helpers

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
  run_command(recipe, task, 'before')
  yield
  run_command(recipe, task, 'after')
end

# run_command finds command for stage on task and executes.
# Examples:
#   uninstall:
#     before: { sudo: rm -Rf }
#     sh:     { echo 'Uninstalling...' }
#     after:  { sh: echo 'Done' }
#
# command keys:
#   sh   - run as shell of current user (Rake sh)
#   sudo - run using sudo
#
# stage:
#   nil     - look for sh/sudo on task
#   <stage> - look for sh/sudo on stage
def run_command(recipe, task, stage=nil)
  return unless recipe.platform.has_key?(task)
  cfg = recipe.platform[task]
  
  unless stage.nil?
    return unless cfg.has_key?(stage)
    cfg = cfg[stage]
  end
  
  # Look for commands (prefer sudo)
  case
  when cfg.has_key?('sudo')
    Bootstrap.sudo cfg['sudo']
  when cfg.has_key?('sh')
    sh cfg['sh']
  end
end

def command_install_task(recipe)
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        run_command(recipe, 'install')
      end
    end
  end
end

def command_uninstall_task(recipe)
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        run_command(recipe, 'uninstall')
      end
    end
  end
end

def mac_pkg_install_task(recipe)
  cfg = recipe.platform['install']
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        Bootstrap::MacOSX::Pkg.install cfg['pkg'], cfg['pkg_id'], recipe.source_url
      end
    end
  end
end

def mac_pkg_uninstall_task(recipe)
  cfg = recipe.platform['uninstall']
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        Bootstrap::MacOSX::Pkg.uninstall cfg['pkg_id']
      end
    end
  end
end

def mac_app_install_task(recipe)
  app = recipe.appbundle
  file app do |t|
    exec_task(recipe, 'install') do
      Bootstrap::MacOSX::App.install recipe.app, recipe.source_url, sig: recipe.sig
    end
  end
  
  namespace "#{recipe.namespace}" do
    task :install => [app]
  end
end

def mac_app_uninstall_task(recipe)
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        Bootstrap::MacOSX::App.uninstall recipe.platform['app']
      end
    end
  end
end

def mac_install_task(recipe)
  cfg = recipe.platform
  key = 'install'
  case
  when cfg.has_key?(key) && cfg[key].has_key?('pkg_id')
    mac_pkg_install_task recipe
  when cfg.has_key?(key) && (cfg[key].has_key?('sh') || cfg[key].has_key?('sudo'))
    command_install_task recipe
  when cfg.has_key?('app')
    mac_app_install_task recipe
  end  
end

def mac_uninstall_task(recipe)
  cfg = recipe.platform
  key = 'uninstall'
  case
  when cfg.has_key?(key) && cfg[key].has_key?('pkg_id')
    mac_pkg_uninstall_task recipe
  when cfg.has_key?(key) && (cfg[key].has_key?('sh') || cfg[key].has_key?('sudo'))
    command_uninstall_task recipe
  when cfg.has_key?('app')
    mac_app_uninstall_task recipe
  end
end

def mac_tasks(recipe)
  about_task recipe
  mac_install_task recipe
  mac_uninstall_task recipe
  update_task recipe
  default_task recipe, recipe.platform['default'] || 'install'
end

def linux_tasks(recipe)
  # TODO: Implement linux task generator
end

def windows_tasks(recipe)
  # TODO: Implement windows task generator
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
