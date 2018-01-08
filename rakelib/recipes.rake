require 'rake'
require 'erb'
require 'pathname'
require 'yaml'

RECIPES_DIR = Pathname.new('recipes')

def generate_mac_tasks(ns, cfg)
  name = cfg['app']
  description = cfg['description']
  homepage = cfg['homepage']
  source_url = cfg['source_url']
  appbundle = File.join("/Applications", name + ".app")
  
  file appbundle do |t|
    Bootstrap::MacOSX::App.install(name, source_url)
  end
  
  desc "About #{name}"
  task "#{ns}:about" do
    Bootstrap.about(name, description, homepage)
  end
  
  desc "Install #{name}"
  task "#{ns}:install" => [:about, appbundle]
  
  desc "Uninstall #{name}"
  task "#{ns}:uninstall" do
    Bootstrap::MacOSX::App.uninstall(name)
  end
end

def generate_linux_tasks(ns, cfg)
  # TODO: Implement linux task generator
end

def generate_windows_tasks(ns, cfg)
  # TODO: Implement windows task generator
end

def namespace_for_config(src)
  p = Pathname.new(src).relative_path_from(RECIPES_DIR)
  File.basename(p.to_s().sub(File::SEPARATOR, ':'), ".*")
end

# Generate tasks from recipes
FileList['recipes/**/*.yml', 'recipes/**/*.yaml'].each do |src|
  ns = namespace_for_config(src)
  cfg = YAML.load_file(src)
  
  case RUBY_PLATFORM
  when /darwin/
    generate_mac_tasks(ns, cfg['macos']) if cfg.include?('macos')
  when /linux/
    generate_linux_tasks(ns, cfg['linux']) if cfg.include?('linux')
  when /windows/
    generate_windows_tasks(ns, cfg['windows']) if cfg.include?('windows')
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
