module Actions
  module Go
    module_function

    # go clean packages
    def clean(args)
      args.each { |pkg| Bootstrap::Go.clean pkg }
    end

    # go get packages
    def get(args)
      args.each { |pkg| Bootstrap::Go.get pkg }
    end
  end
end
