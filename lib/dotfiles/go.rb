module Go
  module_function

  def get(pkg, noinstall=false)
    system "go get -u#{' -d' if noinstall} #{pkg}"
  end

  def clean(pkg)
    system "go clean -i #{pkg}" if Go.exists?(pkg)
  end

  def exists?(pkg)
    p = File.join(`go env GOPATH`, pkg)
    File.exists? p
  end
end
