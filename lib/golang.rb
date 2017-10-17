module Bootstrap
  # go helpers
  module Go
    def get(pkg, noinstall=false)
      Bootstrap.system_echo "go get -u #{'-d' if noinstall} #{pkg}"
    end
    module_function :get

    def clean(pkg)
      Bootstrap.system_echo "go clean -i #{pkg}"
    end
    module_function :clean

    def sudo(cmd)
      Bootstrap::sudo "GOPATH=#{Bootstrap.workspace_dir} #{cmd}"
    end
    module_function :sudo
  end
end
