# macOS rake task helpers

def mac_pkg_install_task(recipe)
  cfg = recipe.platform['install']
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        options = {
          sig:     recipe.sig,
          headers: recipe.headers
        }
        Bootstrap::MacOSX::Pkg.install cfg['pkg'], cfg['pkg_id'], recipe.source_url, options
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
  app = recipe.appbundle(recipe.app)
  file app do |t|
    exec_task(recipe, 'install') do
      options = {
        sig:     recipe.sig,
        headers: recipe.headers
      }
      Bootstrap::MacOSX::App.install recipe.app, recipe.source_url, options
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
        Bootstrap::MacOSX::App.uninstall recipe.app
      end
    end
  end
end

def mac_run_install_task(recipe)
  app = recipe.platform['installer']
  namespace "#{recipe.namespace}" do
    task :install => [:about] do
      exec_task(recipe, 'install') do
        options = {
          sig:     recipe.sig,
          headers: recipe.headers
        }
        Bootstrap::MacOSX::App.installer app, recipe.source_url, options
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
  when cfg.has_key?(key) && cfg[key].has_key?('manifest')
    manifest_install_task recipe
  when cfg.has_key?(key) && Recipe.has_commands?(cfg[key])
    command_install_task recipe
  when cfg.has_key?('app')
    mac_app_install_task recipe
  when cfg.has_key?('installer')
    mac_run_install_task recipe
  end
end

def mac_uninstall_task(recipe)
  cfg = recipe.platform
  key = 'uninstall'
  case
  when cfg.has_key?(key) && cfg[key].has_key?('pkg_id')
    mac_pkg_uninstall_task recipe
  when cfg.has_key?(key) && cfg[key].has_key?('manifest')
    manifest_uninstall_task recipe
  when cfg.has_key?(key) && Recipe.has_commands?(cfg[key])
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
