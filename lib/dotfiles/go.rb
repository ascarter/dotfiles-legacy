module Go
  def get(pkg, noinstall=false)
    Bootstrap.system_echo "go get -u#{' -d' if noinstall} #{pkg}"
  end
  module_function :get

  def clean(pkg)
    Bootstrap.system_echo "go clean -i #{pkg}" if Go.exists?(pkg)
  end
  module_function :clean

  def exists?(pkg)
    gopath = `go env GOPATH`
    File.exists? File.join(gopath, pkg)
  end
  module_function :exists?
end
