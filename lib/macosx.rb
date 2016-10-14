module Bootstrap
  # Mac OS X application helpers
  module MacOSX
    def path_helper(path_file, paths, type = 'paths')
      unless %w(paths manpaths).include?(type)
        raise ArgumentError, 'Invalid path type'
      end

      fullpath = File.join("/etc/#{type}.d", path_file)
      if File.exist?(fullpath)
        warn "#{fullpath} already exists"
      else
        Bootstrap.sudo "touch #{fullpath}"
        paths.each { |p| Bootstrap.sudo "echo '#{p}' >> #{fullpath}" }
      end
    end
    module_function :path_helper

    def rm_path_helper(path_file, type = 'paths')
      fullpath = File.join("/etc/#{type}.d", path_file)
      if File.exist?(fullpath)
        Bootstrap.sudo_rm(fullpath)
      else
        warn "#{fullpath} not found"
      end
    end
    module_function :rm_path_helper

    def run_applescript(script)
      system "osascript \"#{script}\""
    end
    module_function :run_applescript

    def build_locatedb
      Bootstrap.sudo 'launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist'
    end
    module_function :build_locatedb

    # Mac OS X defaults
    module Defaults
      def read(domain, key: nil, options: nil)
        value = `defaults read #{domain} #{options} #{"\"#{key}\"" unless key.nil?}`
        value
      end
      module_function :read

      def write(domain, key, value, options = nil)
        `defaults write #{domain} "#{key}" #{options} "#{value}"`
      end
      module_function :write

      def delete(domain, key: nil, options: {})
        `defaults delete #{domain} #{key.to_s unless key.nil?} #{options}`
      end
      module_function :delete
    end

    # An App is a Mac OS X Application Bundle provied by a dmg, zip, or tar.gz
    # cmdfiles is an optional list of paths on the expanded source
    # to copy to /usr/local/bin
    module App
      def install(app, url, headers: {}, sig: {}, owner: Bootstrap.current_user, group: 'admin', cmdfiles: [], manfiles: [])
        app_name = "#{app}.app"
        app_path = File.join('/Applications', app_name)

        if File.exist?(app_path)
          warn "#{app} already installed"
        else
          Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
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
      module_function :install

      def uninstall(app)
        app_name = "#{app}.app"
        app_path = File.join('/Applications', app_name)

        if File.exist?(app_path)
          puts "Uninstalling #{app}"
          Bootstrap.sudo_rmdir app_path
        else
          warn "#{app} is not installed"
        end
      end
      module_function :uninstall

      # Mac OS X Run helper
      def run(app, url, headers: {}, sig: {})
        Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
          app_name = "#{app}.app"
          app_path = File.join(d, app_name)
          system %(open --wait-apps "#{app_path}")
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
        File.exist?(app_path)
      end
      module_function :exists?
    end

    # Mac OS X Installer Package
    module Pkg
      def install(pkg, id, src, sig: {}, choices: nil, headers: {})
        pkg_name = "#{pkg}.pkg"
        if exists?(id)
          warn "Package #{pkg} already installed"
        else
          Bootstrap::Downloader.download_with_extract(src, headers: headers, sig: sig) do |d|
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
      module_function :install

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
      module_function :uninstall

      def ls(id)
        if system "pkgutil --pkgs=\"#{id.tr('.', "\.")}\""
          files = `pkgutil --only-files --files #{id}`
          dirs = `pkgutil --only-dirs --files #{id}`
          return files.split, dirs.split
        else
          warn "Package #{id} not installed"
        end
      end
      module_function :ls

      def info(id)
        i = {}
        o, _e, s = Open3.capture3("pkgutil --pkg-info #{id}")
        return nil unless s.success?
        o.each_line do |l|
          parts = l.split(':')
          i[parts[0].strip] = parts[1].strip
        end
        i
      end
      module_function :info

      def exists?(id)
        !info(id).nil?
      end
      module_function :exists?
    end

    # Mac OS X Safari Extension
    module SafariExtension
      def install(ext, url, headers: {})
        ext_name = "#{ext}.safariextz"
        downloads_file = File.join(Bootstrap.home_dir, 'Downloads', ext_name)
        Bootstrap::Downloader.download_with_extract(url, headers: headers) do |d|
          ext_path = File.join(d, ext_name)
          system %(ditto "#{ext_path}" "#{downloads_file}")
        end
        system %(open -a Safari --new --fresh "#{downloads_file}")
      end
      module_function :install
    end

    # Mac OS X Font
    module Font
      def install(font, url, font_type: 'otf', headers: {}, sig: {}, owner: Bootstrap.current_user, group: 'admin')
        Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
          src = File.join(d, "#{font}.#{font_type}")
          sh "open #{d}"
          STDIN.gets
          puts "Installing #{font} from #{src}"
          Dir.glob(src).each do |f|
            dest = File.join(Bootstrap.font_dir, File.basename(f))
            puts "Copying #{f} to #{dest}"
            FileUtils.cp(f, dest)
          end
        end
      end
      module_function :install

      def uninstall(font, font_type: 'otf')
        src = File.join(Bootstrap.font_dir, "#{font}.#{font_type}")
        Dir.glob(src).each { |f| FileUtils.rm(f) }
      end
      module_function :uninstall
    end

    # Mac OS X color picker
    module ColorPicker
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
          Bootstrap::Downloader.download_with_extract(url, headers: headers) do |d|
            src = File.join(d, picker_path)
            puts "Installing #{picker}"
            FileUtils.cp_r(src, dest)
          end
        end
      end
      module_function :install

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
      module_function :uninstall
    end
  end
end
