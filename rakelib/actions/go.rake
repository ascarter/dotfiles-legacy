module Actions
  module Go
    # go clean packages
    def clean(args)
      args.each { |pkg| Bootstrap::Go.clean pkg }
    end
    module_function :clean

    # go get packages
    def get(args)
      args.each { |pkg| Bootstrap::Go.get pkg }
    end
    module_function :get
  end
end
