
#
# Mac OS X application helpers
#

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

  #
  # Mac OS X defaults
  #
  
  module Defaults
    def read(domain, key=nil, options=nil)
      value = %x{defaults read #{domain} #{options} #{"\"#{key}\"" unless key.nil?}}
      return value
    end
    module_function :read

    def write(domain, key, value, options=nil)
      %x{defaults write #{domain} "#{key}" #{options} "#{value}"}
    end
    module_function :write

    def delete(domain, key=nil, options=nil)
      cmd = "defaults delete #{domain}"
      %x{defaults delete #{domain} #{"#{key}" unless key.nil?} #{options}}
    end
    module_function :delete
  end

  # An App is a Mac OS X Application Bundle provied by a dmg, zip, or tar.gz
  class App
    attr_reader :name, :source
    
    def initialize(name, source)
      @name = name
      @source = source
    end
    
    def to_s
      return appname
    end
    
    def appname
      return "#{name}.app"
    end
    
    def path
      File.join('/Applications', appname)
    end
    
    def exists?
      return File.exists?(path)
    end
    
    def install
      unless exists?
        download do |d|
          src_path = File.join(d, appname)
          puts "Installing #{name} to #{path}"
          sudo "ditto \"#{src_path}\" \"#{path}\""
        end
      else
        warn "#{@name} already installed"
      end      
    end
    
    def uninstall
      if exists?
        puts "Uninstalling #{name}"
        sudo_remove_dir path
      else
        warn "#{@name} is not installed" unless exists?
      end
    end
    
    def hide
      script = "tell application \"Finder\" to set visible process \"#{app}\" to false"
      system "osascript -e '#{script}'"
    end
    
    def download
      puts "Requesting #{@source}"
      Downloader.download_to_tempdir(@source) do |p|
        ext = File.extname(p)
        case ext
        when ".zip"
          Downloader.unzip(p) { |d| yield d }
        when ".dmg"
          Downloader.mount_dmg(p) { |d| yield d }
        else
          raise "Download package format #{ext} not supported"
        end
      end
    end
  end
  
  # A Package is a Mac OS X Installer Package provided by a dmg, zip, or tar.gz
#   class Package
#   end
end