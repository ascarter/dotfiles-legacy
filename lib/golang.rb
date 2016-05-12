#
# go helpers
#

module Bootstrap
  module Go
    def get(workspace, pkg)
      ENV['GOPATH'] = workspace
      cmd = "go get -u #{pkg}"
      puts cmd
      system cmd
    end
    module_function :get
  end
end
