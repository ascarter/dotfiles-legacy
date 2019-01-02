module NodeJS
  module_function

  def version
    puts "Node.js: #{`/usr/local/bin/node --version`}"
    puts "npm:     #{`/usr/local/bin/npm --version`}"
  end
end

# NPM helpers

module NPM
  module_function

  def install(pkg)
    puts "Installing npm package #{pkg}..."
    sudo "npm install --global #{pkg}"
  end

  def update(pkg = '')
    puts "Updating npm package #{pkg}..."
    sudo "npm update --global #{pkg}"
  end

  def uninstall(pkg)
    puts "Uninstalling npm package #{pkg}..."
    sudo "npm uninstall --global #{pkg}"
  end

  def installed?(pkg)
    _o, _e, s = Open3.capture3("npm list --global --parseable #{pkg}")
    s.exitstatus.zero?
  end

  def list
    packages = []
    `npm list --global --parseable --depth=0`.split("\n").each do |pkg|
      pkg_name = File.basename(pkg)
      unless %w(lib npm).include?(pkg_name)
        packages.push(File.basename(pkg_name))
      end
    end
    packages
  end

  def ls
    puts 'Installed npm modules:'
    list.each { |pkg| puts " #{pkg}" }
  end
end
