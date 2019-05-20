module MacOS
  module_function

  def path_helper(path_file, paths)
    sudo <<-END
      mkdir -p #{File.dirname(path_file)}
      touch #{path_file}
    END
    paths.each { |p| sudo "echo '#{p}' >> #{path_file}" }
  end

  def run_app(app, wait: false)
    flags = wait ? "--wait-apps" : ""
    system %(open #{flags} "#{App.path(app)}")
  end

  def run_applescript(script)
    system %(osascript "#{script}")
  end

  def build_locatedb
    domain = 'com.apple.locate'
    locate_plist = '/System/Library/LaunchDaemons/com.apple.locate.plist'
    sudo "launchctl list #{domain} 2&>1 > /dev/null || launchctl load -w #{locate_plist}"
  end
end
