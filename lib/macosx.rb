# Mac OS X application helpers

module Bootstrap
  module MacOSX
    def path_helper(path_file, paths, type='paths')
      raise ArgumentError, "Invalid path type" unless ['paths', 'manpaths'].include? type

      fullpath = File.join("/etc/#{type}.d", path_file)
      unless File.exist?(fullpath)
        FileTools.sudo "touch #{fullpath}"
        paths.each { |p| FileTools.sudo "echo '#{p}' >> #{fullpath}" }
      else
        warn "#{fullpath} already exists"
      end
    end
    module_function :path_helper

    def run_applescript(script)
      system "osascript \"#{script}\""
    end
    module_function :run_applescript

    # Mac OS X defaults
    module Defaults
      def read(domain, key: nil, options: {})
        value = %x{defaults read #{domain} #{options} #{"\"#{key}\"" unless key.nil?}}
        return value
      end
      module_function :read

      def write(domain, key, value, options=nil)
        %x{defaults write #{domain} "#{key}" #{options} "#{value}"}
      end
      module_function :write

      def delete(domain, key: nil, options: {})
        cmd = "defaults delete #{domain}"
        %x{defaults delete #{domain} #{"#{key}" unless key.nil?} #{options}}
      end
      module_function :delete
    end

    # An App is a Mac OS X Application Bundle provied by a dmg, zip, or tar.gz
    # cmdfiles is an optional list of paths on the expanded source to copy to /usr/local/bin
    module App
      def install(app, url, headers: {}, sig: nil, cmdfiles: [])
        app_name = "#{app}.app"
        app_path = File.join('/Applications', app_name)
      
        unless File.exists?(app_path)
          Bootstrap.download_with_extract(url, headers: headers, sig: sig) do |d|
            src_path = File.join(d, app_name)
            puts "Installing #{app} to #{app_path}"
            Bootstrap.sudo_cpr src_path, app_path
            Bootstrap.sudo_chown(app_path, 'root')
            Bootstrap.sudo_chgrp(app_path, 'admin')
            cmdfiles.each { |f| Bootstrap.sudo_cp(File.join(d, f), File.join('/usr/local/bin', File.basename(f))) }
          end
        else
          warn "#{app} already installed"
        end
      end
      module_function :install
  
      def uninstall(app)
        app_name = "#{app}.app"
        app_path = File.join('/Applications', app_name)
      
        if File.exists?(app_path)
          puts "Uninstalling #{app}"
          Bootstrap.sudo_rmdir app_path
        else
          warn "#{app} is not installed"
        end
      end
      module_function :uninstall
    
      # Mac OS X Run helper
      def run(app, url, headers: {})
        Bootstrap.download_with_extract(url, headers: headers) do |d|
          app_name = "#{app}.app"
          app_path = File.join(d, app_name)
          system %Q{open --wait-apps "#{app_path}"}
        end
      end
      module_function :run
    
      def hide(app)
        script = "tell application \"Finder\" to set visible process \"#{app}\" to false"
        system "osascript -e '#{script}'"
      end
      module_function :hide
      
      def exists?(app)
        app_name = "#{app}.app"
        app_path = File.join('/Applications', app_name)
        return File.exists?(app_path)
      end
      module_function :exists?
    end
  
    # Mac OS X Installer Package
    module Pkg
      def install(pkg, id, src, sig: nil, choices: nil, headers: {})
        pkg_name = "#{pkg}.pkg"
        unless exists?(id)
          Bootstrap.download_with_extract(src, headers: headers, sig: sig) do |d|
            src_path = File.join(d, pkg_name)
            puts "Installing #{pkg}"
            cmd = %Q{installer -package "#{src_path}" -target /}
            if !choices.nil?
              if !File.exist?(choices)
                raise "Choices file #{choices} not found"
              end
              cmd += %Q{ -applyChoiceChangeXML "#{choices}"}
            end
            Bootstrap.sudo cmd
          end
        else
          warn "Package #{pkg} already installed"
        end
      end
      module_function :install
    
      def uninstall(id, dryrun=false)
        i = info(id)
        puts "pkg info: #{i}" if dryrun

        if i
          files, dirs = ls(id)

          # Remove files
          files.each do |f|
            path = File.expand_path(File.join(i["volume"], i["location"], f))
            Bootstrap.sudo_rm(path) unless dryrun
          end

          # Forget package
          Bootstrap.sudo "pkgutil --forget #{id}" unless dryrun

          # Don't remove directories - this needs to be per package so return them
          return dirs
        else
          puts "Package #{id} is not installed"
        end
      end    
      module_function :uninstall

      def ls(id)
        if system "pkgutil --pkgs=\"#{id.gsub(".", "\.")}\""
          files = %x{pkgutil --only-files --files #{id}}
          dirs = %x{pkgutil --only-dirs --files #{id}}
          return files.split, dirs.split
        else
          warn "Package #{id} not installed"
        end
      end
      module_function :ls

      def info(id)
        i = {}
        o, e, s = Open3.capture3("pkgutil --pkg-info #{id}")
        return nil unless s.success?
        o.each_line do |l|
          parts = l.split(':')
          i[parts[0].strip] = parts[1].strip
        end
        return i
      end
      module_function :info

      def exists?(id)
        return !info(id).nil?
      end
      module_function :exists?
    end
    
    # Mac OS X Safari Extension
    module SafariExtension
      def install(ext, url, headers: {})
        ext_name = "#{ext}.safariextz"
        downloads_file = File.join(Bootstrap.home_dir, 'Downloads', ext_name)
        Bootstrap.download_with_extract(url, headers: headers) do |d|
          ext_path = File.join(d, ext_name)
          system %Q{ditto "#{ext_path}" "#{downloads_file}"}
        end
        system %Q{open -a Safari --new --fresh "#{downloads_file}"}
      end
      module_function :install
    end
    
    # Mac OS X color picker
    module ColorPicker
      def install(picker, url, headers: {})
        picker_name = "#{File.basename(picker)}.colorPicker"
        picker_path = File.join(File.dirname(picker), picker_name)
        dest = File.join(Bootstrap.home_dir(), 'Library', 'ColorPickers', picker_name)
        unless File.exists?(dest)
          Bootstrap.download_with_extract(url, headers: headers) do |d|
            src = File.join(d, picker_path)
            puts "Installing #{picker}"
            FileUtils.cp_r(src, dest)
          end
        else
          warn "#{picker} already installed"
        end
      end
      module_function :install
      
      def uninstall(picker)
        picker_name = "#{picker}.colorPicker"
        picker_path = File.join(Bootstrap.home_dir(), 'Library', 'ColorPickers', picker_name)
        if File.exists?(picker_path)
          puts "Uninstalling #{picker}"
          FileUtils.rm_rf(picker_path)
        else
          warn "#{picker} is not installed"
        end
      end
      module_function :uninstall
    end
  end
end
