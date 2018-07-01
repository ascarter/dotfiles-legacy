module Actions
  module NPM
    module_function

    # npm install -g <pkgs>
    def install(args)
      args.each { |pkg| Bootstrap::NPM.install pkg }
    end

    # npm uninstall -g <pkgs>
    def uninstall(args)
      args.each { |pkg| Bootstrap::NPM.uninstall pkg }
    end
  end
end
