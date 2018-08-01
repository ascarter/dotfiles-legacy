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
        MacOS::Pkg.install cfg['pkg'], cfg['pkg_id'], recipe.source_url, options
      end
    end
  end
end

def mac_pkg_uninstall_task(recipe)
  cfg = recipe.platform['uninstall']
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        MacOS::Pkg.uninstall cfg['pkg_id']
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
      MacOS::App.install recipe.app, recipe.source_url, options
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
        MacOS::App.uninstall recipe.app
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
        MacOS::App.installer app, recipe.source_url, options
      end
    end
  end
end

def mac_run_uninstall_task(recipe)
  app = recipe.platform['installer']
  namespace "#{recipe.namespace}" do
    task :uninstall do
      exec_task(recipe, 'uninstall') do
        MacOS.run
        options = {
          sig:     recipe.sig,
          headers: recipe.headers
        }
        MacOS::App.installer app, recipe.source_url, options
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
  when cfg.has_key?('installer')
    mac_run_uninstall_task recipe
  end
end

def mac_tasks(recipe)
  about_task recipe
  mac_install_task recipe
  mac_uninstall_task recipe
  update_task recipe
  default_task recipe, recipe.platform['default'] || 'install'
end

# macOS application helpers

module MacOS
  module_function
  
  def path_helper(path_file, paths, type = 'paths')
    unless %w(paths manpaths).include?(type)
      raise ArgumentError, "Invalid path type #{type}"
    end

    fullpath = File.join("/etc/#{type}.d", path_file)
    if File.exist?(fullpath)
      warn "#{fullpath} already exists"
    else
      Bootstrap.sudo "mkdir -p #{File.dirname(fullpath)}"
      Bootstrap.sudo "touch #{fullpath}"
      paths.each { |p| Bootstrap.sudo "echo '#{p}' >> #{fullpath}" }
    end
  end

  def rm_path_helper(path_file, type = 'paths')
    fullpath = File.join("/etc/#{type}.d", path_file)
    if File.exist?(fullpath)
      Bootstrap.sudo_rm(fullpath)
    else
      warn "#{fullpath} not found"
    end
  end

  def run_app(app, wait: false)
    flags = wait ? "--wait-apps" : ""
    system %(open #{flags} "#{App.path(app)}")
  end

  def run_applescript(script)
    system "osascript \"#{script}\""
  end

  def build_locatedb
    Bootstrap.sudo 'launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist'
  end

  # Mac OS X defaults
  module Defaults
    module_function
    
    def read(domain, key: nil, options: nil)
      value = `defaults read #{domain} #{options} #{"\"#{key}\"" unless key.nil?}`
      value
    end

    def write(domain, key, value, options = nil)
      `defaults write #{domain} "#{key}" #{options} "#{value}"`
    end

    def delete(domain, key: nil, options: {})
      `defaults delete #{domain} #{key.to_s unless key.nil?} #{options}`
    end
  end

  # An App is a Mac OS X Application Bundle provied by a dmg, zip, or tar.gz
  # cmdfiles is an optional list of paths on the expanded source
  # to copy to /usr/local/bin
  module App
    module_function

    def install(app, url, headers: {}, sig: {}, owner: Bootstrap.current_user, group: 'admin', cmdfiles: [], manfiles: [])
      app_name = "#{app}.app"
      app_path = path(app)

      if File.exist?(app_path)
        warn "#{app} already installed"
      else
        Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
          src_path = File.join(d, app_name)
          puts "Installing #{app} to #{app_path}"
          Bootstrap.sudo_cpr(src_path, app_path)
          Bootstrap.sudo_chown(app_path, owner)
          Bootstrap.sudo_chgrp(app_path, group)
          cmdfiles.each { |f| Bootstrap.usr_bin_cp(File.join(d, f)) }
          manfiles.each { |f| Bootstrap.usr_man_cp(File.join(d, f)) }
        end
      end
    end

    def uninstall(app)
      app_path = path(app)

      if File.exist?(app_path)
        puts "Uninstalling #{app}"
        Bootstrap.sudo_rmdir app_path
      else
        warn "#{app} is not installed"
      end
    end

    # Mac OS X Run helper
    def run(app, url, headers: {}, sig: {}, wait: false)
      open_flags = wait ? "--wait-apps" : ""
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        MacOS.run_app(app, wait: wait)
      end
    end

    # Mac OS X installer app
    def installer(app, url, headers: {}, sig: {})
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        launch(File.join(d, "#{app}.app"), wait: true)
      end
    end

    def launch(app, wait: false)
      flags = wait ? "--wait-apps" : ""
      system %(open #{flags} -a "#{app}")
    end

    def hide(app)
      script = "tell application \"Finder\" to set visible process \"#{app}\" to false"
      system "osascript -e '#{script}'"
    end

    def path(app)
      File.join('/Applications', "#{app}.app")
    end

    def contents(app)
      File.join(path(app), 'Contents')
    end

    def exists?(app)
      File.exist?(path(app))
    end
  end

  # Mac OS X Installer Package
  module Pkg
    module_function

    def install(pkg, id, src, sig: {}, choices: nil, headers: {})
      pkg_name = "#{pkg}.pkg"
      if exists?(id)
        warn "Package #{pkg} already installed"
      else
        Downloader.download_with_extract(src, headers: headers, sig: sig) do |d|
          src_path = File.join(d, pkg_name)
          puts "Installing #{pkg}"
          cmd = %(installer -package "#{src_path}" -target /)
          unless choices.nil?
            unless File.exist?(choices)
              raise "Choices file #{choices} not found"
            end
            cmd += %( -applyChoiceChangeXML "#{choices}")
          end
          Bootstrap.sudo cmd
        end
      end
    end

    def uninstall(id, dryrun = false)
      i = info(id)
      puts "pkg info: #{i}" if dryrun

      if i
        files, dirs = ls(id)

        # Remove files
        files.each do |f|
          path = File.expand_path(File.join(i['volume'], i['location'], f))
          Bootstrap.sudo_rm(path) unless dryrun
        end

        # Forget package
        Bootstrap.sudo "pkgutil --forget #{id}" unless dryrun

        # Don't remove directories
        # this needs to be per package so return them
        return dirs
      else
        puts "Package #{id} is not installed"
      end
    end

    def ls(id)
      if system "pkgutil --pkgs=\"#{id.tr('.', "\.")}\""
        files = `pkgutil --only-files --files #{id}`
        dirs = `pkgutil --only-dirs --files #{id}`
        return files.split, dirs.split
      else
        warn "Package #{id} not installed"
      end
    end

    def info(id)
      i = {}
      o, _e, s = Open3.capture3("pkgutil --pkg-info '#{id}'")
      return nil unless s.success?
      o.each_line do |l|
        parts = l.split(':')
        i[parts[0].strip] = parts[1].strip
      end
      i
    end

    def exists?(id)
      !info(id).nil?
    end
  end

  # Mac app plugin
  # Many apps have plugins that can be installed by opening the plugin and letting
  # the app handle it.
  #
  # Examples:
  #   sketchplugin
  #   bbpackage
  module Plugin
    module_function

    def install(plugin, url, headers: {}, sig: {})
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        target = File.join(d, plugin)
        system %(open "#{target}")
      end
    end
  end

  # Mac OS X script
  module Script
    module_function

    # run downloads and executes script
    def run(script, url, flags: [], headers: {}, sig: {}, wait: false)
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        script_path = File.join(d, script)
        system %("#{script_path}" #{flags.join(" ")})
      end
    end

    # sudo downloads and executes script via sudo
    def sudo(script, url, flags: [], headers: {}, sig: {}, wait: false)
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        script_path = File.join(d, script)
        Bootstrap.sudo %("#{script_path}" #{flags.join(" ")})
      end
    end
  end

  # Mac OS X Safari Extension
  module SafariExtension
    module_function

    def install(ext, url, headers: {})
      ext_name = "#{ext}.safariextz"
      downloads_file = File.join(Bootstrap.home_dir, 'Downloads', ext_name)
      Downloader.download_with_extract(url, headers: headers) do |d|
        ext_path = File.join(d, ext_name)
        system %(ditto "#{ext_path}" "#{downloads_file}")
      end
      system %(open -a Safari --new --fresh "#{downloads_file}")
    end
  end

  # Mac OS X Font
  module Font
    module_function

    def install(font, url, font_type: 'otf', headers: {}, sig: {}, owner: Bootstrap.current_user, group: 'admin')
      Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        src = File.join(d, "#{font}.#{font_type}")
        puts "Installing #{font} from #{src}"
        Dir.glob(src).each do |f|
          dest = File.join(Bootstrap.font_dir, File.basename(f))
          puts "Copying #{f} to #{dest}"
          FileUtils.cp(f, dest)
        end
      end
    end

    def uninstall(font, font_type: 'otf')
      src = File.join(Bootstrap.font_dir, "#{font}*.#{font_type}")
      Dir.glob(src).each { |f| FileUtils.rm(f) }
    end
  end

  # Mac OS X color picker
  module ColorPicker
    module_function

    def install(picker, url, headers: {})
      picker_name = "#{File.basename(picker)}.colorPicker"
      picker_path = File.join(File.dirname(picker), picker_name)
      dest = File.join(Bootstrap.home_dir,
                       'Library',
                       'ColorPickers',
                       picker_name)
      if File.exist?(dest)
        warn "#{picker} already installed"
      else
        Downloader.download_with_extract(url, headers: headers) do |d|
          src = File.join(d, picker_path)
          puts "Installing #{picker}"
          FileUtils.cp_r(src, dest)
        end
      end
    end

    def uninstall(picker)
      picker_name = "#{picker}.colorPicker"
      picker_path = File.join(Bootstrap.home_dir,
                              'Library',
                              'ColorPickers',
                              picker_name)
      if File.exist?(picker_path)
        puts "Uninstalling #{picker}"
        FileUtils.rm_rf(picker_path)
      else
        warn "#{picker} is not installed"
      end
    end
  end
end
