require 'rake'
require 'erb'
require 'pathname'
require 'yaml'

RECIPES_DIR = Pathname.new('recipes')

# Keep about tasks implicit
def about_task(ns, name, description='', homepage='')
  namespace "#{ns}" do
    task :about do
      puts "#{description}"
      puts "#{homepage}"
    end
  end
end

def mac_tasks(ns, cfg)
  name = ns.split(":")[-1]
  description = cfg['description']
  homepage = cfg['homepage']
  source_url = cfg['source_url']

  # Add about task
  about_task(ns, name, description, homepage)

  # Add install task
  if cfg.has_key?('install')
    if cfg['install'].has_key?('pkg_id')
      namespace "#{ns}" do
        desc "Install #{name}"
        task :install => [:about] do
          Bootstrap::MacOSX::Pkg.install(cfg['install']['pkg'], cfg['install']['pkg_id'], source_url)
        end
      end
    end
  elsif cfg.has_key?('app')
    # mac app install
    appbundle = File.join("/Applications", cfg['app'] + ".app")

    file appbundle do |t|
      Bootstrap::MacOSX::App.install(name, source_url)
    end

    namespace "#{ns}" do
      desc "Install #{name}"
      task :install => [:about, appbundle]
    end
  end

  # Add uninstall task
  if cfg.has_key?('uninstall')
    if cfg['uninstall'].has_key?('pkg_id')
      namespace "#{ns}" do
        desc "Uninstall #{name}"
        task :uninstall do
          Bootstrap::MacOSX::Pkg.uninstall(cfg['uninstall']['pkg_id'])
        end
      end
    end
  elsif cfg.has_key?('app')
    # mac app uninstall
    namespace "#{ns}" do
      desc "Uninstall #{name}"
      task :uninstall do
        Bootstrap::MacOSX::App.uninstall(cfg['app'])
      end
    end
  end
end

def linux_tasks(ns, cfg)
  # TODO: Implement linux task generator
end

def windows_tasks(ns, cfg)
  # TODO: Implement windows task generator
end

# namespace_for_config converts yaml file path to be a namespace relative to recipes directory
def namespace_for_config(src)
  p = Pathname.new(src).relative_path_from(RECIPES_DIR).to_s()
  File.basename(p.sub(File::SEPARATOR, ':'), ".*")
end

# Generate tasks from recipes
FileList['recipes/**/*.yml', 'recipes/**/*.yaml'].each do |src|
  ns = namespace_for_config(src)
  cfg = YAML.load_file(src)

  case RUBY_PLATFORM
  when /darwin/
    mac_tasks(ns, cfg['macos']) if cfg.include?('macos')
  when /linux/
    linux_tasks(ns, cfg['linux']) if cfg.include?('linux')
  when /windows/
    windows_tasks(ns, cfg['windows']) if cfg.include?('windows')
  end
end

desc "Generator for new recipes"
task :create do
  ns = Bootstrap.prompt("task name (namespace using ':')")
  parts = ns.split(':')
  name = parts[-1]
  target = File.join(RECIPES_DIR, parts[0..-2], name + '.yml')

  template = <<-EOB
# #{name}

macos:
    app: #{name}
    description: About #{name}
    homepage: http://example.com/#{name}/
    source_url: http://example.com/#{name}/download

  EOB

  body = ERB.new(template).result(binding)
  mkdir_p File.dirname(target)
  File.open(target, 'w') { |f| f.write(body) }
end
