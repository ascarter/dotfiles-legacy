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
    sudo 'launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist'
  end
end
