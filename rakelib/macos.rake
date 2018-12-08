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
      Bootstrap.sudo_mkdir File.dirname(fullpath)
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
end
