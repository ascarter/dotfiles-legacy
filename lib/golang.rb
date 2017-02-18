module Bootstrap
  # go helpers
  module Go
    def get(pkg)
      Bootstrap.system_echo "go get -u #{pkg}"
    end
    module_function :get

    def clean(pkg)
      Bootstrap.system_echo "go clean -i #{pkg}"
    end
    module_function :clean
  end
end
